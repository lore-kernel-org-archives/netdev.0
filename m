From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: CVE-2014-9900 fix is not upstream
Date: Thu, 25 Aug 2016 14:41:08 +0200
Message-ID: <1472128868.24772.12.camel@sipsolutions.net>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
         <20160823.094029.1244944495918162255.davem@davemloft.net>
         <1471973727.13300.162.camel@decadent.org.uk>
         <20160823.112406.549221808236512285.davem@davemloft.net>
         <20160823200941.GB2356@ZenIV.linux.org.uk>
         <1471984445.3746.129.camel@perches.com>
         <20160823204933.GA14311@csclub.uwaterloo.ca>
         <20160823212545.GC2356@ZenIV.linux.org.uk>
         <20160824140316.GB14309@csclub.uwaterloo.ca>
         <18517b44-0d3f-3f83-e327-60064c170c5a@stressinduktion.org>
         (sfid-20160824_223642_965094_F10174F7) <1472128800.24772.11.camel@sipsolutions.net>
         (sfid-20160825_144034_137293_6B5C4140)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
        ben@decadent.org.uk, luis.henriques@canonical.com,
        avijitnsec@codeaurora.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
        Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472128800.24772.11.camel@sipsolutions.net> (sfid-20160825_144034_137293_6B5C4140)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> struct ethtool_wolinfo {
>         __u32   cmd;
>         __u32   supported;
>         __u32   wolopts;
>         __u8    sopass[SOPASS_MAX];     // 6, actually
> };
> 
> we could do
> 
> struct ethtool_wolinfo {
>         __u32   cmd;
>         __u32   supported;
>         __u32   wolopts;
>         __u8    sopass[SOPASS_MAX];     // 6, actually
> 	__u8	reserved[2];
> };
> 
> and then the compiler has to properly treat it, since it's no longer
> unnamed padding.
> 

Although, on some architectures, that could actually break the ABI by
changing the size, oh well.

johannes
