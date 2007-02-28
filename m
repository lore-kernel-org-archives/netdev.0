From: John <linux.kernel@free.fr>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Wed, 28 Feb 2007 14:37:49 +0100
Message-ID: <45E585AD.8050704@free.fr>
References: <45E5570E.7050301@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux.kernel@free.fr
To: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <45E5570E.7050301@free.fr>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John wrote:

> I know it's possible to have Linux timestamp incoming datagrams as soon
> as they are received, then for one to retrieve this timestamp later with
> an ioctl command or a recvmsg call.

Has it ever been proposed to modify struct skb_timeval to hold 
nanosecond stamps instead of just microsecond stamps? Then make the 
improved precision somehow available to user space.

On a related note, the comment for skb_set_timestamp() states:

/**
  * skb_set_timestamp - set timestamp of a skb
  * @skb: skb to set stamp of
  * @stamp: pointer to struct timeval to get stamp from
  *
  * Timestamps are stored in the skb as offsets to a base timestamp.
  * This function converts a struct timeval to an offset and stores
  * it in the skb.
  */

But there is no mention of an offset in the code:

static inline void skb_set_timestamp(
   struct sk_buff *skb, const struct timeval *stamp)
{
   skb->tstamp.off_sec  = stamp->tv_sec;
   skb->tstamp.off_usec = stamp->tv_usec;
}

Likewise for skb_get_timestamp:

/**
  * skb_get_timestamp - get timestamp from a skb
  * @skb: skb to get stamp from
  * @stamp: pointer to struct timeval to store stamp in
  *
  * Timestamps are stored in the skb as offsets to a base timestamp.
  * This function converts the offset back to a struct timeval and stores
  * it in stamp.
  */

static inline void skb_get_timestamp(
   const struct sk_buff *skb, struct timeval *stamp)
{
   stamp->tv_sec  = skb->tstamp.off_sec;
   stamp->tv_usec = skb->tstamp.off_usec;
}

Are the comments related to code that has since been modified?

Regards.
