From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 4/6] net: ethernet: ti: cpts: add ptp pps support
Date: Fri, 2 Dec 2016 11:58:34 -0600
Message-ID: <bfbebf2d-d057-6a21-845c-48f0a9ab0404@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-5-grygorii.strashko@ti.com>
 <20161130184511.GB8209@netboy> <875d4cc2-8a47-b06d-fb46-0cacc28dbaee@ti.com>
 <20161130221738.GA13099@localhost.localdomain>
 <20161202095848.GA14586@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161202095848.GA14586@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On 12/02/2016 03:58 AM, Richard Cochran wrote:
> On Wed, Nov 30, 2016 at 11:17:38PM +0100, Richard Cochran wrote:
>> On Wed, Nov 30, 2016 at 02:43:57PM -0600, Grygorii Strashko wrote:
>>> Sry, but this is questionable - code for pps comes from TI internal
>>> branches (SDK releases) where it survived for a pretty long time.
> 
> Actually, there is a way to get an accurate PPS from the am335x.  See
> this recent thread:
> 
>    https://www.mail-archive.com/linuxptp-devel@lists.sourceforge.net/msg01726.html
> 
> That is the way to go, and so, please drop this present patch.
> 

thanks for the links - it sounds very interesting.

As I understood, people trying to enable PPS on am335 device with the
goal to have PPS signal generated on some SoC pin and therefore they use DMtimer.
Also, as i understood, the Timer Load Register (TLDR) is corrected once
a second at each HW_TS_PUSH - as result, if freq was corrected during current sec
there will be some HW_TS_PUSH generation jitter any way.

Above solution is a bit complex for keystone 2 SoCs, as CPTS itself on these SoCs has
output pin (ts_comp) which can be used for PPS signal generation. So, I think,
similar results can be achieved by removing PPS correction code from cpts_ptp_adjfreq()
and updating CPTS_TS_LOAD_VAL once a sec in cpts_overflow_check().

or I missed smth?

-- 
regards,
-grygorii
