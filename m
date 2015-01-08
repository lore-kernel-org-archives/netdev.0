From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP connection issues against Amazon S3
Date: Thu, 08 Jan 2015 10:52:58 -0800
Message-ID: <54AED20A.4060806@hp.com>
References: <5DCDADEF-FF9C-4844-8A2C-62E2D3B3B8CE@bengler.no> <8C4F7938-DCA1-46F5-A3C9-7DF62511DEE7@bengler.no> <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com> <03FC652E-AA01-42C7-BD52-019B6D922A9C@bengler.no> <CAK6E8=cP0BFUob5MVj9M0hC0efgRnUY=JMUPKee+v-4TLvHBgg@mail.gmail.com> <76DC89D1-CFCE-44B7-994E-4349FEEDEFA6@bengler.no> <1420575216.5947.12.camel@edumazet-glaptop2.roam.corp.google.com> <4DA8529D-4EEC-42DA-89B0-DC7746DB2B10@bengler.no> <3F608393-E5F1-4647-81BF-C6C740100934@bengler.no> <CAK6E8=cf7cROQ0SON0BihkbOsBB+-sLAbexxgt4_xD+Auqev3Q@mail.gmail.com> <34CE0233-F881-4F40-B119-AA9D8F7D500F@bengler.no> <1420646284.5947.19.camel@edumazet-glaptop2.roam.corp.google.com> <A58F8257-97F8-4662-98FC-7AC57F35A3A4@bengler.no> <1420666401.5947.35.camel@edumazet-glaptop2.roam.
 corp.google.com> <DCC8B9AB-D1D7-4722-9B65-93AB5A559763@bengler.no> <1420740936.5947.70.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Erik Grinaker <erik@bengler.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420740936.5947.70.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Strange thing is that sender does not misbehave at the beginning when
> receiver window is still small. Only after a while.

Just guessing, but when the receiver window is small, the sender cannot 
get a large quantity of data out there at once, so any string of lost 
packets will tend to be smaller.  If the sender is relying on the RTO to 
trigger the retransmits, and is not resetting his RTO until the clean 
ACK of a segment sent after snd_nxt when the loss is detected, the 
smaller loss strings will not get to the rather large RTO values seen in 
the trace before curl gives-up.  It may be that the sender is indeed 
misbehaving at the beginning, just that it isn't noticeable?

Different but perhaps related observation/question - without timestamps 
(which we don't have in this case), isn't there a certain ambiguity 
about arriving out-of-order segments? One doesn't really know if they 
are out-of-order because the network is re-ordering, or because they are 
retransmissions of segments we've not yet seen at the receiver.

rick
