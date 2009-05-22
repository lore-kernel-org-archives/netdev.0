From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/2] net: Allow protocols to provide an unlocked_recvmsg
 sk_prot method
Date: Fri, 22 May 2009 00:47:38 -0700 (PDT)
Message-ID: <20090522.004738.139438566.davem@davemloft.net>
References: <20090520230659.GC5956@ghostprotocols.net>
	<200905221026.51789.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@redhat.com, netdev@vger.kernel.org, vanhoof@redhat.com,
	williams@redhat.com
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37470
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751368AbZEVHrj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2009 03:47:39 -0400
In-Reply-To: <200905221026.51789.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Fri, 22 May 2009 10:26:51 +0300

> On Thursday 21 May 2009 02:06:59 ext Arnaldo Carvalho de Melo wrote:
>> @@ -265,6 +265,9 @@ struct ucred {
>>  #define MSG_ERRQUEUE	0x2000	/* Fetch message from error queue */
>>  #define MSG_NOSIGNAL	0x4000	/* Do not generate SIGPIPE */
>>  #define MSG_MORE	0x8000	/* Sender will send more */
>> +#ifdef __KERNEL__
>> +#define MSG_UNLOCKED	0x10000	/* Don't lock the sock */
>> +#endif
>=20
> I might be missing something but... What prevents an evil userland fr=
om=20
> setting the flag anyway and hitting the BUG case?

Yes, we'll need to clear this on all paths where we get msg
flags from the user.

There's a lot of such places.

So maybe we need to pass this state around in a different,
internal, way.
