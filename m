From: "David S. Miller" <davem@redhat.com>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Wed, 08 Jan 2003 15:06:38 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030108.150638.09647984.davem@redhat.com>
References: <Pine.LNX.4.33.0301081451110.2281-100000@dyn9-47-18-86.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jgrimm2@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sri@us.ibm.com
In-Reply-To: <Pine.LNX.4.33.0301081451110.2281-100000@dyn9-47-18-86.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Sridhar Samudrala <sri@us.ibm.com>
   Date: Wed, 8 Jan 2003 15:04:53 -0800 (PST)
   
   1. Add a new argument to ip_queue_xmit() to pass the value of DF bit.
   2. Use the __unused field in skb to pass the value of DF bit.
   3. Let SCTP call its own routine that fills in the ip header with the
      appropriate value in the DF bit, but this duplicates most of the code
      in ip_queue_xmit(). Also ip_options_build() needs to be exported.
   
   Which option do you prefer? Or can you suggest any better alternative?

Too bad there's not a 4th option, fix SCTP.  This is really broken
that the data stream can get into a state where resegmentation cannot
be performed.

Sigh... I guess the new argument to ip_queue_xmit() is the least
intrusive.
