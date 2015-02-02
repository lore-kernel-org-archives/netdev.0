From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Mon, 02 Feb 2015 15:06:03 -0800
Message-ID: <1422918363.21689.132.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	 <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	 <1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	 <1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54CFEB46.3050006@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	eyalpe-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54CFEB46.3050006-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-02-02 at 13:25 -0800, Ben Greear wrote:

> It is a big throughput win to have fewer TCP ack packets on
> wireless since it is a half-duplex environment.  Is there anything
> we could improve so that we can have fewer acks and still get
> good tcp stack behaviour?

First apply TCP stretch ack fixes to the sender. There is no way to get
good performance if the sender does not handle stretch ack.

d6b1a8a92a14 tcp: fix timing issue in CUBIC slope calculation
9cd981dcf174 tcp: fix stretch ACK bugs in CUBIC
c22bdca94782 tcp: fix stretch ACK bugs in Reno
814d488c6126 tcp: fix the timid additive increase on stretch ACKs
e73ebb0881ea tcp: stretch ACK fixes prep

Then, make sure you do not throttle ACK too long, especially if you hope
to get Gbit line rate on a 4 ms RTT flow.

GRO does not mean : send one ACK every ms, or after 3ms delay...

It is literally :
  aggregate X packets at receive, and send the ACK asap.

If the receiver expects to have 64 ACK packets in the TX ring buffer to
actually send them (wifi aggregation), then you certainly do not want to
compress ACK too much.



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
