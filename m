From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Configuring the same IP on multiple addresses
Date: Mon, 29 Oct 2007 13:36:36 -0700
Message-ID: <OFA7162E78.5F05251C-ON88257383.006F837E-88257383.00711D0D@us.ibm.com>
References: <4726381A.6050002@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:58952 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318AbXJ2Ugi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 16:36:38 -0400
In-Reply-To: <4726381A.6050002@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> For v6, there are plenty of operational reasons to not allow this.  You 
really
> turn unicast into anycast when you do this and there are special rules 
to
> be followed.

        I don't see it that way. The only "problem" I can think of offhand
is that you can't use a multi-interface address to identify an interface
(for example, for multicasting) and get predictable results (it'll pick
the first one it finds with that address, in no particular order). But
you can still use interface indexes, which are unique.
        Anycast is used for multiple distinct hosts, which isn't an issue
on the same host. It's already true, as you pointed out, that you can
receive a packet for any local address on any interface, so allowing
multiple instances means you still match it as local. Which interface
you match it on usually isn't relevant, and when it is are exactly the
cases where using duplicates might be appropriate.
        I can see where it might be useful if you have policy
restrictions on some interfaces and want the particular address
to be both in and out of a set. But, I agree, it's generally more
trouble (for an administrator), but then administrators don't have
to assign the same address to multiple interfaces. 

                                                        +-DLS

