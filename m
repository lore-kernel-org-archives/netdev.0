From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IFA_MAX sets wrong in rtnetlink.h
Date: Fri, 28 May 2004 13:48:02 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040528.134802.953480362.yoshfuji@linux-ipv6.org>
References: <200405261319.55787.mashirle@us.ibm.com>
	<200405261350.39088.mashirle@us.ibm.com>
	<20040526135610.2ecaa96a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040526135610.2ecaa96a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040526135610.2ecaa96a.davem@redhat.com> (at Wed, 26 May 2004 13:56:10 -0700), "David S. Miller" <davem@redhat.com> says:

> On Wed, 26 May 2004 13:50:39 -0700
> Shirley Ma <mashirle@us.ibm.com> wrote:
> 
> > A tiny patch here for 2.6.6 kernel.
> 
> Good catch, patch applied.

BTW, how do you think of the code below to minimize diffs and risk of error
when we add new item for enum?

enum {
     :
     IFA_MULTICAST,
     __IFA_MAX
};

#define IFA_MAX (__IFA_MAX - 1)

-----
enum {
     :
     IFA_CACHEINFO
};

#define IFA_MAX IFA_CACHEINFO

enum {
     :
     IFA_CACHEINFO,  /* changed to add "," */
     IFA_MULTICAST   /* added */
};

#define IFA_MAX IFA_MULTICAST /* changed */

--- vs ---

enum {
     :
     IFA_CACHEINFO,
     __IFA_MAX
};

#define IFA_MAX (__IFA_MAX - 1)

enum {
     :
     IFA_CACHEINFO,
     IFA_MULTICAST,   /* added */
     __IFA_MAX
};

#define IFA_MAX (__IFA_MAX - 1)

--yoshfuji
