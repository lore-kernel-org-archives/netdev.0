From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] ipv4: netfilter: always let NUL terminated string
 ended by '\0'
Date: Thu, 23 May 2013 14:26:31 +0200
Message-ID: <20130523122631.GA32141@localhost>
References: <5195ECB3.5000006@asianux.com>
 <20130523110832.GB22553@localhost>
 <519E0296.6010601@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <519E0296.6010601@asianux.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 23, 2013 at 07:50:46PM +0800, Chen Gang wrote:
> 
> For NUL terminated string, need always be sure of ended by '\0'.
> 
> 'prefix' max length is 128 (NF_LOG_PREFIXLEN), and 'pm->prefix' max
> length is 32 (ULOG_PREFIX_LEN), so really need notice it.
> 
> 'pm' is 'struct ulog_packet_msg_t' which may be copied to user mode
> (defined in "include/uapi/..."), so can not use strlcpy() instead of.

That's fixing a real bug. We're passing strings that are longer than
32 bytes from nf_conntrack_tcp via nf_log, if ipt_ULOG is used, it
will pass a non-null terminated string.

I'm going to rework the patch description to include this and apply
this patch.

Thanks Chen.
