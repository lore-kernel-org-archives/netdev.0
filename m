From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 0/5] SCTP updates
Date: Wed, 09 Jul 2014 12:30:34 -0400
Message-ID: <53BD6E2A.4050303@gmail.com>
References: <1404507908-6949-1-git-send-email-dborkman@redhat.com> <20140708111408.GA23026@hmsreliant.think-freely.org> <53BBFAA6.80408@redhat.com> <20140708144127.GB23026@hmsreliant.think-freely.org> <53BD1211.4080504@redhat.com> <20140709104958.GA3784@hmsreliant.think-freely.org> <53BD4363.70306@redhat.com> <20140709151354.GA5250@localhost.localdomain> <53BD6167.1030000@gmail.com> <20140709154428.GD5250@localhost.localdomain> <063D6719AE5E284EB5DD2968C1650D6D1726F39D@AcuExch.aculab.com> <1AA30289-FE48-4E1E-90CF-8E567D8A1031@lurchi.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"geirola@gmail.com" <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: Michael Tuexen <Michael.Tuexen@lurchi.franken.de>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:34146 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbaGIQai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 12:30:38 -0400
In-Reply-To: <1AA30289-FE48-4E1E-90CF-8E567D8A1031@lurchi.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2014 12:12 PM, Michael Tuexen wrote:
> On 09 Jul 2014, at 18:02, David Laight <David.Laight@ACULAB.COM> wrote:
> 
>> From: Neil Horman
>> ...
>>>> The problem here is deprecation of ancillary data and that's is a lot tougher
>>>> then socket options.  In this particular case (SCTP_SNDRCVINFO vs SCTP_RCVINFO),
>>>> I don't think there is any way to deprecate the SCTP_SNDRCVINFO since the event
>>>> enabling it is the same as the one for SCTP_RCVINFO.  This was a mistake in the
> I don't think this is true:
> To request SCTP_SNDRCVINFO you use the SCTP_EVENTS option. See
> http://tools.ietf.org/html/rfc6458#section-6.2.1
> To request the SCTP_RCVINFO you use the SCTP_RECVRCVINFO option. See
> http://tools.ietf.org/html/rfc6458#section-8.1.29
> So the user does different things and the kernel can provide the requested
> information.

This is not very clear, but yes.  I've re-re-read the section in question after
sending out that mail and yes this does seem to be the case.

-vlad

> 
> Best regards
> Michael
>>>> spec.  Ancillary data should not have been enabled using even notification api,
>>>> as it is not an event, but we now have to live with it.
>>>>
>>> Ugh I didn't even consider cmsg type overlap.  Thats probably it then, we can't
>>> deprecate it.  Though that does call the question up as to how to differentiate
>>> expectations of the data format for each cmsg, if they use the same type.  Does
>>> the SCTP_RCVINFO data struct overlay the SNDRCVINFO struct exactly?  (sorry I've
>>> not checked myself yet).
>>
>> Not from what I remember from when I read that RFC.
>> I think the lengths are different enough to determine which is which.
>>
>> That RFC (I've forgotten the number) looks like an entire bag of poo
>> that should be ignored...
>>
>> 	David
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
