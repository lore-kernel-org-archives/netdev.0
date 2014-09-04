From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Thu, 04 Sep 2014 07:32:09 -0700
Message-ID: <1409841129.26422.117.camel@edumazet-glaptop2.roam.corp.google.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Denis Kirjanov <kirjanov@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:46404 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbaIDOcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 10:32:15 -0400
Received: by mail-pa0-f50.google.com with SMTP id kq14so20056660pab.23
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 07:32:12 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174876B4@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-04 at 14:23 +0000, David Laight wrote:
> From: Eric Dumazet
> > On Thu, 2014-09-04 at 15:40 +0200, Hannes Frederic Sowa wrote:
> > 
> > > The type does not matter at all. Actually I wanted to use an empty
> > > struct but was afraid it might not work on older compilers and didn't
> > > want to check that with each version.
> > 
> > 
> > It matters. Really.
> > 
> > $ cat try.c
> > #include <stdio.h>
> > 
> > struct S_int {
> > 	char a;
> > 	int offset[0];
> > 	char b:1;
> > };
> > 
> > struct S_char {
> > 	char a;
> > 	char offset[0];
> > 	char b:1;
> > };
> 
> Those are also both illegal C, zero sized arrays aren't allowed.
> 
> 	David


This does not matter, we already use such constructs in the kernel.

Take a look at kmemcheck_bitfield_begin() for example.
