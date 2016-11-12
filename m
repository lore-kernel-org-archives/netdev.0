From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] genetlink: fix unsigned int comparison with less than
 zero
Date: Sat, 12 Nov 2016 22:37:16 +0100
Message-ID: <1478986636.4226.4.camel@sipsolutions.net>
References: <20161110155758.26996-1-colin.king@canonical.com>
         <CAM_iQpW=q4nm97dNouSL19Cr2cEWT9xQHXAm4CNJk=AY8z_2MA@mail.gmail.com>
         (sfid-20161110_181214_593279_4F3243C4)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        pravin shelar <pshelar@ovn.org>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        Florian Westphal <fw@strlen.de>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpW=q4nm97dNouSL19Cr2cEWT9xQHXAm4CNJk=AY8z_2MA@mail.gmail.com> (sfid-20161110_181214_593279_4F3243C4)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-11-10 at 09:11 -0800, Cong Wang wrote:
> On Thu, Nov 10, 2016 at 7:57 AM, Colin King <colin.king@canonical.com
> > wrote:
> > 
> > From: Colin Ian King <colin.king@canonical.com>
> > 
> > family->id is unsigned, so the less than zero check for
> > failure return from idr_alloc is never true and so the error exit
> > is never handled.  Instead, assign err and check if this is less
> > than zero since this is a signed integer.
> 
> Why family->id can't be just signed int? For me it should be.

I suppose it could be, since family IDs are allocated in a 16-bit range
anyway. But family IDs can also never actually be negative, so having
an unsigned int in the struct makes sense too.

I tend to think this patch is fine.

johannes
