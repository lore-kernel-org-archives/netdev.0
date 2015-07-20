From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: Re: [PATCH] nohz: prevent tilegx network driver interrupts
Date: Mon, 20 Jul 2015 17:22:12 -0400
Message-ID: <55AD6684.3080607@ezchip.com>
References: <1436549624-16104-1-git-send-email-cmetcalf@ezchip.com>
 <20150710182406.GC26428@lerouge> <55A0175E.2010200@ezchip.com>
 <20150711143033.GE10257@lerouge>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150711143033.GE10257@lerouge>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/11/2015 10:30 AM, Frederic Weisbecker wrote:
> On Fri, Jul 10, 2015 at 03:05:02PM -0400, Chris Metcalf wrote:
>> The tilegx chips typically don't do cpu offlining anyway, since
>> we've never really found a usecase, so whatever you boot with
>> you always have available.  We do have support for a bare-metal
>> mode which you can run on some of the cores, so you may start
>> with fewer than cpu_possible actually running, but it will always
>> be that same set of cores.
> And that bare metal mode runs out of Linux?

The bare metal environment runs on cpus that have been marked
as unavailable to Linux, so Linux just sees them as permanently
offlined.  There is a BME driver (which we haven't upstreamed,
since the BME isn't upstreamed either) that arranges to share
memory between the BME and Linux.

I don't think that many customers are using the BME in any
case.  We push all of them towards using our dataplane mode
instead, since it almost always works just as well from a
performance perspective, and is easier to develop code for.

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com
