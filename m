From: apetlund@simula.no
Subject: Re: [PATCH 3/3] net: TCP thin dupack
Date: Thu, 29 Oct 2009 16:23:53 +0100
Message-ID: <879da81bfa8a9f0f34717c64b08332ed.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andreas Petlund" <apetlund@simula.no>,
	"Netdev" <netdev@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	"David Miller" <davem@davemloft.net>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755299AbZJ2PXv@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I apologise that some of you received this mail more than once. My email
client played a HTML-trick on me.

>> +	/* If a thin stream is detected, retransmit after first
>> +	 * received dupack */
>> +	if ((tp->thin_dupack || sysctl_tcp_force_thin_dupack) &&
>> +	    tcp_dupack_heurestics(tp) > 1 && tcp_stream_is_thin(tp))
>> +		return 1;
>> +
>>  	return 0;
>>  }
>
> Have you tested it? ...I doubt this will work like you say and
retransmit
> something when the window is small. ...Besides, you should have built
this
> patch on top of the function rename you submitted earlier as after DaveM
applied that this will no longer even compile...
>
> --
>  i.
>

We have performed extensive tests mapping the effect of the patch you
commented on some months ago. Since then, the only change was the one you
requested of switching tcp_fackets_out() with tcp_dupack_heurestics().
After inspecting the code, I believed the effect should be equal to the
previous, only making considerations for SACK and FACK availability.
Please tell if this will break the intended effect, and I will modify the
patch accordingly.

Graphs from our tests of the original patch can be found at the location
linked to below.  I have tested the new one for functionality, but have
not et performed tests on this scope as the changes were minor. I will, of
course, fix the function rename in the next iteration. Sorry for that.

http://folk.uio.no/apetlund/lktmp/

-AP
