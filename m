From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Thu, 4 Sep 2014 13:51:18 -0700
Message-ID: <CAADnVQL6s_DRE2aMEw=oBdcu6Bn0Q5CfZ_CKJ4xdGdcp5cRV7w@mail.gmail.com>
References: <1409778511-21273-1-git-send-email-kda@linux-powerpc.org>
	<54078FBC.5050402@redhat.com>
	<CAADnVQKNHL7iY=VHp4bs5k2hSDf8jy7H-0H0SgYjb81S25XB9Q@mail.gmail.com>
	<1409792893.26422.60.camel@edumazet-glaptop2.roam.corp.google.com>
	<1409793959.3362714.163402573.6A26EDE1@webmail.messagingengine.com>
	<1409796348.26422.76.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAADnVQLh6qOD2epUq0S5P8RkUgZA38JNxeP40uBMScLHC2SsJg@mail.gmail.com>
	<CAHj3AVn8q-JS0Eq0QrfpBo-WfJ+-wXumhNoeDAdkPZC7LSeB5g@mail.gmail.com>
	<1409831412.23465.3.camel@localhost>
	<1409836154.26422.101.camel@edumazet-glaptop2.roam.corp.google.com>
	<1409838010.23465.16.camel@localhost>
	<1409839892.26422.115.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D174876B4@AcuExch.aculab.com>
	<1409841129.26422.117.camel@edumazet-glaptop2.roam.corp.google.com>
	<1409841233.23465.22.camel@localhost>
	<1409841347.26422.118.camel@edumazet-glaptop2.roam.corp.google.com>
	<1409841709.23465.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	Denis Kirjanov <kirjanov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:43979 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755256AbaIDUvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 16:51:19 -0400
Received: by mail-qa0-f46.google.com with SMTP id w8so9930738qac.5
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 13:51:18 -0700 (PDT)
In-Reply-To: <1409841709.23465.25.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 4, 2014 at 7:41 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Do, 2014-09-04 at 07:35 -0700, Eric Dumazet wrote:
>> On Thu, 2014-09-04 at 16:33 +0200, Hannes Frederic Sowa wrote:
>>
>> > Which btw. also uses int, which might change alignment of structures.
>>
>> You missed the point .
>>
>> kmemcheck wants to make sure the whole word is set, or else you could
>> get false positives.
>>
>> kmemcheck needs are quite different.
>
> Now that you said it, I understand. :)
>
> You were right with the int vs. u8 thing all along. gcc aligns the
> datatype on the next struct field and not on the whole field, as I
> expected. So excuse my error above.
>
> I think the latest proposals looks good?

to me: yes
and I think your latest half-patch with:
+       __u8                    __pkt_type_offset[0];
also looks good.

Are you going to take it over from Denis here?

while at it would you fix sparc jit as well that has comment:
#if 0
                                /* GCC won't let us take the address of
                                 * a bit field even though we very much
                                 * know what we are doing here.
                                 */
                        case BPF_ANC | SKF_AD_PKTTYPE:
                                __emit_skb_load8(pkt_type, r_A);
                                emit_alu_K(SRL, 5);
                                break;
#endif
should be able to replace 'pkt_type' above with __pkt_type_offset...
