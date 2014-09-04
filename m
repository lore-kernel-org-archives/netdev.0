From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Thu, 04 Sep 2014 16:41:49 +0200
Message-ID: <1409841709.23465.25.camel@localhost>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Denis Kirjanov <kirjanov@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:44233 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753677AbaIDOlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 10:41:53 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id BA10120959
	for <netdev@vger.kernel.org>; Thu,  4 Sep 2014 10:41:52 -0400 (EDT)
In-Reply-To: <1409841347.26422.118.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2014-09-04 at 07:35 -0700, Eric Dumazet wrote:
> On Thu, 2014-09-04 at 16:33 +0200, Hannes Frederic Sowa wrote:
> 
> > Which btw. also uses int, which might change alignment of structures.
> 
> You missed the point .
> 
> kmemcheck wants to make sure the whole word is set, or else you could
> get false positives.
> 
> kmemcheck needs are quite different.

Now that you said it, I understand. :)

You were right with the int vs. u8 thing all along. gcc aligns the
datatype on the next struct field and not on the whole field, as I
expected. So excuse my error above.

I think the latest proposals looks good?
