From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: Improving OCTEON II 10G Ethernet performance
Date: Thu, 25 Aug 2016 13:11:45 -0700
Message-ID: <57BF5101.6080909@caviumnetworks.com>
References: <CAO_EM_nrb0M49YwU+gjL+bqT4V1rFj4z7DQ8juTYXgaoKet0mg@mail.gmail.com>
 <57BF21C7.5070709@caviumnetworks.com>
 <20160825182210.GE12169@raspberrypi.musicnaut.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: driverdev-devel <devel@driverdev.osuosl.org>,
 linux-mips <linux-mips@linux-mips.org>, netdev <netdev@vger.kernel.org>,
 David Daney <ddaney@caviumnetworks.com>,
 Aaro Koskinen <aaro.koskinen@nokia.com>
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160825182210.GE12169@raspberrypi.musicnaut.iki.fi>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 08/25/2016 11:22 AM, Aaro Koskinen wrote:
> Hi,
>
> On Thu, Aug 25, 2016 at 09:50:15AM -0700, David Daney wrote:
>> Ideally we would configure the packet classifiers on the RX side to create
>> multiple RX queues based on a hash of the TCP 5-tuple, and handle each queue
>> with a single NAPI instance.  That should result in better performance while
>> maintaining packet ordering.
>
> Would this need anything else than reprogramming CVMX_PIP_PRT_TAGX, and
> eliminating the global pow_receive_group and creating multiple NAPI instances
> and registering IRQ handlers?
>

That is essentially how it works.  Set the tag generation parameters, 
and use the low order bits of the tag to select which POW/SSO group is 
assigned.  The SSO group corresponds to an "rx queue"


> In the Yocto tree, the CVMX_PIP_PRT_TAGX register values are actually
> documented:
>
> http://git.yoctoproject.org/cgit/cgit.cgi/linux-yocto-contrib/tree/arch/mips/include/asm/octeon/cvmx-pip-defs.h?h=apaliwal/octeon#n3737

Wow, I didn't realize that documentation was made public.


>
> A.
>
