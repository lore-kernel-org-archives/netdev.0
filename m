From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 03 Nov 2015 19:03:26 +0100
Message-ID: <5638F6EE.10505@hartkopp.net>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <CAAP7ucKWT++AbPPA2kvm965JSjsgCm0OMf0-Vnjwe-ck+xjZZQ@mail.gmail.com> <5638EF9C.9070503@hartkopp.net> <201511031841.09549.marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Aleksander Morgado <aleksander@aleksander.es>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.218]:29689 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754277AbbKCSDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 13:03:32 -0500
In-Reply-To: <201511031841.09549.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2015 06:41 PM, Marek Vasut wrote:
> On Tuesday, November 03, 2015 at 06:32:12 PM, Oliver Hartkopp wrote:
> 
> [...]
> 
>> It looks like you need to shift the stuff in user space every time.
>>
>> So you might better think of something like this:
>>
>>     struct a429_frame {
>>             __u32   label;   /* ARINC 429 label */
>>             __u8    length;  /* always set to 8 */
>>             __u8    __pad;   /* padding */
>>             __u8    __res0;  /* reserved / padding */
>>             __u8    __res1;  /* reserved / padding */
>>             __u32   data __attribute__((aligned(8)));
>>             __u8    p;       /* p */
>>             __u8    ssm;     /* ssm */
>>             __u8    sdi;     /* sdi */
>>             __u8    __end;   /* padding */
>>     };
> 
> You don't want to interpret those P(arity)/SSM/SDI bits, since they differ
> depending on whatever the remote party sends. That's why I decided to just
> make those into 3-bytes of data and let the userland application deal with
> it as seen fit. Besides, the ARINC "FTP" really uses those 3 bytes as plain
> data.

Ok. I did not know what P was for :-)

Btw. it can make sense to introduce an union struct where different options to
access the content are possible.

E.g. you might have a 32 bit word, some bit-wise specification and a four byte
tuple to access the three bytes for ARINC FTP ...

Regards,
Oliver
