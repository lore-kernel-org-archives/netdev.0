From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipv4: netfilter: always let NUL terminated string ended
 by '\0'
Date: Thu, 23 May 2013 13:49:50 +0200
Message-ID: <20130523114950.GA4972@localhost>
References: <5195ECB3.5000006@asianux.com>
 <20130523110832.GB22553@localhost>
 <519DFFFB.40104@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <519DFFFB.40104@asianux.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 23, 2013 at 07:39:39PM +0800, Chen Gang wrote:
> On 05/23/2013 07:08 PM, Pablo Neira Ayuso wrote:
> > On Fri, May 17, 2013 at 04:39:15PM +0800, Chen Gang wrote:
> >> >
> >> > For NUL terminated string, better always be sure of ended by '\0'.
> >> >
> >> > 'pm' is 'struct ulog_packet_msg_t' which may be copied to user mode
> >> > (defined in "include/uapi/..."), so can not use strlcpy() instead of.
> > loginfo->prefix is always nul-terminated, as this is validated in
> > checkentry. I don't think the kernel will take a non nul-terminated
> > device name either.
>
> Really it is.
>
> And 'prefix' max length is 128 (NF_LOG_PREFIXLEN), and 'pm->prefix' max
> length is 32 (ULOG_PREFIX_LEN), so we still need this patch, but need
> improved.

Both are ULOG_PREFIX_LEN long.

>From include/uapi/linux/netfilter_ipv4/ipt_ULOG.h:

/* private data structure for each rule with a ULOG target */
struct ipt_ulog_info {
        unsigned int nl_group;
        size_t copy_range;
        size_t qthreshold;
        char prefix[ULOG_PREFIX_LEN];
};

/* Format of the ULOG packets passed through netlink */
typedef struct ulog_packet_msg {
        unsigned long mark;
        long timestamp_sec;
        long timestamp_usec;
        unsigned int hook;
        char indev_name[IFNAMSIZ];
        char outdev_name[IFNAMSIZ];
        size_t data_len;
        char prefix[ULOG_PREFIX_LEN];
        unsigned char mac_len;
        unsigned char mac[ULOG_MAC_LEN;
        unsigned char payload[0];
} ulog_packet_msg_t;
