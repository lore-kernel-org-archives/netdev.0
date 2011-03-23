From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-2.6] bonding: fix rx_handler locking
Date: Wed, 23 Mar 2011 22:16:00 +0100
Message-ID: <20110323211559.GA2809@psychotron.redhat.com>
References: <1300797492-16128-1-git-send-email-jpirko@redhat.com>
 <4D8A4931.10903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	fubar@us.ibm.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44430 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755141Ab1CWVQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 17:16:12 -0400
Content-Disposition: inline
In-Reply-To: <4D8A4931.10903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 23, 2011 at 08:25:37PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 22/03/2011 13:38, Jiri Pirko a =E9crit :
>>This prevents possible race between bond_enslave and bond_handle_fram=
e
>>as reported by Nicolas by moving rx_handler register/unregister.
>>slave->bond is added to hold pointer to master bonding sructure. That
>>way dev->master is no longer used in bond_handler_frame.
>>Also, this removes "BUG: scheduling while atomic" message
>>
>>Reported-by: Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>
>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>
>Thanks Jiri, it works.
>
>Tested-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
>
>Regarding the code review, can you explain the reasons why you
>apparently duplicated the fields related to the slave/master
>relationship?
>
>Do you plan to totally remove dev->master usage in bonding in a follow=
-up patch?

dev->master could be possibly retired. Not sure yet. It's on my todo
list.
>
>	Nicolas.
