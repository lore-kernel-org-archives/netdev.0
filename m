From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [GENETLINK] some thoughts on the usage
Date: Wed, 15 Aug 2007 19:50:09 +0200
Message-ID: <20070815175009.GA32236@postel.suug.ch>
References: <46BC25A6.7000703@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Richard MUSIL <richard.musil@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:40618 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755237AbXHORtt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 13:49:49 -0400
Content-Disposition: inline
In-Reply-To: <46BC25A6.7000703@st.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Richard MUSIL <richard.musil@st.com> 2007-08-10 10:45
> I have noticed that although ops for each family are the same (each
> device is functionally same) I cannot use same genl_ops struct for
> registration, because it uses internal member to link in list. Therefore
> it is necessary to allocate new genl_ops for each device and pass it to
> registration. But I cannot "officially" use this list to track those
> genl_ops (so I can properly destroy them later), because there is no
> interface. So I need to redo the management of the structures on my own.

The intended usage of the interface in your example would be to register
only one genetlink family, say "tpm", register one set of operations
and then have an attribute in every message which specifies which TPM
device to use. This helps keeping the total number of genetlink families
down.

> The second "inconvenience" is that for each family I register, I also
> register basically same ops (basically means, the definitions, and doit,
> dumpit handlers are same, though the structures are at different
> addresses for reasons described above). When the handler receives the
> message it needs to associate the message with the actual device it is
> handling. This could be done through family lookup (using
> nlmsghdr::nlmsg_type), but I wondered if it would make sense to extend
> genl_family for user custom data pointer and then pass this custom data
> (or genl_family reference) to each handler (for example inside
> genl_info). It is already parsed by genetlink layer, so it should not
> slow things down.

That's not a bad idea, although I think we should try and keep the
generic netlink part as simple as possible. There is a family specific
header, referred to as user header in genl_info which is basically
what you're looking for with the custom header. I believe making the
generic netlink family aware of anything beyond family id and operations
id only complicates things.
