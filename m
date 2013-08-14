From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: TCP Connection teardown seems to violate TCP specification
Date: Wed, 14 Aug 2013 22:46:40 +0200
Message-ID: <1376513200.5581.10.camel@nexus>
References: <1376508095.4596.12.camel@nexus>
 <CAK6E8=fWOe3eEvw6sC=Da415qGp+wXsm2bpe9Vbbukit9yU8sQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-out-1.rwth-aachen.de ([134.130.5.186]:38624 "EHLO
	mx-out-1.rwth-aachen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933004Ab3HNUqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 16:46:40 -0400
Received: from [192.168.0.131] ([unknown] [178.201.100.77])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0MRJ00FJRGDRP530@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Wed, 14 Aug 2013 22:46:39 +0200 (CEST)
In-reply-to: <CAK6E8=fWOe3eEvw6sC=Da415qGp+wXsm2bpe9Vbbukit9yU8sQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've seen this with wget 1.14 and curl 7.30.0 on 3.11-rc5 (Gentoo),
with wget 1.15 and curl 7.26.0 on 3.5.7 (other Gentoo machine),
with wget 1.12 and curl 7.19.7 on 2.6.32 (Centos 6.4),

Regards
 Damian

Am Mittwoch, den 14.08.2013, 12:50 -0700 schrieb Yuchung Cheng:
> On Wed, Aug 14, 2013 at 12:21 PM, Damian Lukowski
> <damian@tvk.rwth-aachen.de> wrote:
> > Hi,
> >
> > the TCP specification states that an endpoint has to accept
> > packets from the other side even after it has half-closed the
> > connection locally. This does not seem to be the case
> > under Linux?
> >
> > For example, when I wget -O /dev/null https://www.verisign.com/
> > --max-redir 0, the local TCP stack sends an FIN,ACK close to the end.
> > However, the webserver has more data to send (Encrypted Alert).
> > Instead of ACKing the packet, the local side sends a RST.
> > This seems wrong to me.
> 
> Which wget are you using? it's not doing half-close (i.e.,
> shutdown(SHUT_WR)) on my wget version 1.13.4
> 
> 
> >
> > Regards
> >  Damian
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
