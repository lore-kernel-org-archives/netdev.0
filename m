From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Can I limit the number of active tx per TCP socket?
Date: Thu, 6 Mar 2014 15:03:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6D3F7B@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6D3B91@AcuExch.aculab.com>
 <CABrhC0kpuuHFxgr8BsJA3rTcoo49mb6nOYcuomwsRMPq=p1wQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'John Heffner' <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53611 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750794AbaCFPDw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 10:03:52 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 29140-05 for <netdev@vger.kernel.org>;
 Thu,  6 Mar 2014 15:03:44 +0000 (GMT)
In-Reply-To: <CABrhC0kpuuHFxgr8BsJA3rTcoo49mb6nOYcuomwsRMPq=p1wQA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Heffner 
> On Thu, Mar 6, 2014 at 7:28 AM, David Laight <David.Laight@aculab.com> wrote:
> > Is it possible to stop a TCP connection having more than one
> > tx skb (in the ethernet tx ring) at any one time?
> > The idea is to allow time for short sends from the application
> > to accumulate so that the transmitted frames are longer.
>
> Is TCP_CORK what you're looking for?

No - TCP_CORK requires that you know you have more data to send.
In which case you are better off saving the system calls and
sending it with sendv() or writev().

I may well write the code to sit on the data for up to a ms
before sending it.  The data is sent out on a 64k line so
1ms is only 8 byte times.

	David
