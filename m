From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 10 Jul 2008 16:12:58 +0200
Message-ID: <200807101612.59380.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <200807071518.10912.thomas.jarosch@intra2net.com> <Pine.LNX.4.64.0807101457380.13027@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0807101457380.13027@blackhole.kfki.hu>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, 10. July 2008 15:17:53 you wrote:
> It looks as the smtp server receives the packets slowly and it's just
> behind the client. There's no more packet to/from port 53132 in the
> tcpdump.

Thanks for looking into this, Jozsef. If you take a look at the timing 
information, the connection was already running ~270 seconds without real 
data transfer. The mailserver then aborts the SMTP connection with the error 
msg: "421 mailbackup.webpage.t-com.de Lost connection to [217.85.147.6]"
Only after that the port is "changed" to the wrong one.

The time ranges between the retransmissions seem
to really go downhill after the first retransmission.

The linux box is connected via a mostly idle 2 mbit SDSL line, the mailserver
is located at the provider. So theoretically this shouldn't be slow at all.
This is also proved as 2.6.23.17 works without trouble.

As noted before, small mails below ~220kb always seem to get through.
Is there any feature in TCP that could trigger such a behaviour?
This smells like some queue getting full. I'll double check
there is not some kind of traffic shaping in place.

> > 13:44:51.681540 IP mailserver.smtp > linux.41085: P
> ...
>
> But the first packet above from the server looks just wrong in the
> context: the port of the client "changed". This is why the client sends
> the RST packet back as there's no such TCP connection there.
>
> Makes no sense at all...
>
> [Wild guessing: broken virtualized SMTP server migration?]

Oh, that really looks strange. Maybe the error handling
of the server/load balancer/whatever is broken.

The Fritz!box router-in-between worked fine for a day, but now we just had 
another mail stuck in the queue. So it seems to soften the problem a bit,
but does not solve it.

Thomas
