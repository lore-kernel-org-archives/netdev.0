From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v6] net: ip, diag -- Add diag interface for raw sockets
Date: Thu, 13 Oct 2016 10:16:48 +0300
Message-ID: <20161013071648.GA1946@uranus.lan>
References: <20161006100055.GA1941@uranus.lan>
 <20161012.015022.2273537782016406180.davem@davemloft.net>
 <20161012065329.GH1941@uranus.lan>
 <20161012.195504.658773172040030000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jhs@mojatatu.com,
        dsa@cumulusnetworks.com, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161012.195504.658773172040030000.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 12, 2016 at 07:55:04PM -0400, David Miller wrote:
> From: Cyrill Gorcunov <gorcunov@gmail.com>
> Date: Wed, 12 Oct 2016 09:53:29 +0300
> 
> > I can't rename the field, neither a can use union.
> 
> Remind me again what is wrong with using an anonymous union?

Anon union would be a preferred but Eric pointed me that even
though it might cause problems (https://patchwork.kernel.org/patch/9353365/)

 | Note that some programs could fail to compile with the added union
 | anyway.
 |
 | Some gcc versions are unable to compile a static init with an union
 |
 | struct inet_diag_req_v2 foo = { .pad = 0, sdiag_family = AF_INET, };
 |
 | When I cooked my recent fq commit I simply removed a pad and replaced
 | it :
 |
 | git show fefa569a9d4bc4 -- include
