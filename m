From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: REGRESSION f54b311142a92ea2e42598e347b84e1655caf8e3 tcp auto
 corking slows down iSCSI file system creation by factor of 70 [WAS: 4 TB
 VMFS creation takes 15 minutes vs 26 seconds]
Date: Sat, 08 Feb 2014 07:06:26 -0800
Message-ID: <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140207075536.GB17815@glanzmann.de>
	 <1391801597.1155.28.camel@haakon3.risingtidesystems.com>
	 <20140207205142.GA8609@glanzmann.de> <20140208093808.GD16336@glanzmann.de>
	 <1391865273.10160.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391866389.10160.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391867404.10160.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391868816.10160.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208141905.GG20512@glanzmann.de>
	 <1391869805.10160.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208150001.GI20512@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140208150001.GI20512@glanzmann.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-02-08 at 16:00 +0100, Thomas Glanzmann wrote:
> Hello Eric,
> 
> > Idea would be to set this flag when calling sendmsg() of the 48 bytes
> > of the header, and not set it on the sendmsg() of the 512 bytes of the
> > payload.
> 
> I see.
> 
> > iscsi_sw_tcp_xmit_segment() already adds MSG_MORE, but
> > it would be nice to add a new _initial_ flags parameter to
> > iscsi_sw_tcp_xmit_segment()
> 
> This is for the iscsi initiator implementation. I'm interested in iSCSI
> target code, but I already found it and experiemented a little bit, but
> I need to dig deeper if I want to prepare a patch.

Fantastic !

Let me know if you want some help.

Note : We did some patches in the MSG_MORE logic for sendpage(), but in
your case I do not think its related

(git grep -n MSG_SENDPAGE_NOTLAST ) if you are curious
