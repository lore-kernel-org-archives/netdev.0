From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: Re: [PATCH v4 3/5] net: ethernet: cpsw: introduce ti,am3352-cpsw
 compatible string
Date: Fri, 23 Aug 2013 14:10:38 -0400
Message-ID: <5217A59E.4090700@ti.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com>
 <1377267365-24057-4-git-send-email-zonque@gmail.com>
 <52177052.1030308@ti.com> <52178E20.5040404@gmail.com>
 <52179448.1020906@ti.com> <5217974B.5090503@ti.com> <521799A3.7080706@ti.com>
 <52179AD6.8090406@gmail.com> <52179BDA.50603@ti.com>
 <52179E44.5030202@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, sergei.shtylyov@cogentembedded.com, d-gerlach@ti.com,
 netdev@vger.kernel.org, vaibhav.bedia@ti.com, Daniel Mack <zonque@gmail.com>,
 devicetree@vger.kernel.org, bcousson@baylibre.com, ujhelyi.m@gmail.com,
 linux-omap@vger.kernel.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <52179E44.5030202@ti.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Friday 23 August 2013 01:39 PM, Sekhar Nori wrote:
> On 8/23/2013 10:58 PM, Santosh Shilimkar wrote:
>> On Friday 23 August 2013 01:24 PM, Daniel Mack wrote:
>>> On 23.08.2013 19:19, Santosh Shilimkar wrote:
>>>> On Friday 23 August 2013 01:09 PM, Sekhar Nori wrote:
>>>>> On 8/23/2013 10:26 PM, Santosh Shilimkar wrote:
>>>
>>>>>> So just stick the IP version or call it cpsw-v1... cpsw-v2 etc.
>>>>>
>>>>> If this could be handled using IP version then the right way would be to
>>>>> just read the IP version from hardware and use it. No need of DT property.
>>>>>
>>>> Thats fine as well but I thought the patch needed additional properties like
>>>> CM reg-address come from DT and hence the separate compatible. If you can
>>>> manage without that, thats even better.
>>>
>>> We can't, that's the whole point :)
>>>
>> I saw that from the patch :)
>>
>>> Well, theoretically, we could for now, but that's not a clean solution.
>>> Again: the problem here is that the control port is separated from the
>>> cpsw core, and so we have to implement something specific for the AM3352
>>> SoC. I know that's a violation of clean and generic driver ideas, but
>>> there's no way we can assume that every cpsw v2 ip block has a control
>>> port that is compatible to the one found on am335x chips.
>>>
>> But there is a possibility that other SOC will just use the same
>> control module approach. So using a revision IP is just fine. BTW,
> 
> But this is misleading because it makes appear like the same compatible
> can be used on on another SoC like DRA7 which probably has the same
> version of IP but a different control module implementation, when in
> practice it cannot.
> 
> The fact is we are doing something SoC specific in the driver and we
> cannot hide that behind IP versions. If really in practice there comes
> another SoC with the same control module definition then it can always
> use ti,am3352-cpsw compatible as well. The compatible name does not
> preclude its usage.
> 
My point was the CPSW needs a feature which is implemented using
control module rather than within the IP itself. Its an implementation
detail. As such the additional feature makes sense for that IP. O.w
there was no need to do any monkeying with control module.

E.g
MMC card detect is a basic functionality, implemented by various types
like control module, PMIC or MMC IP itself. As such the driver need
that support and all the implementation details needs to still handled
to make that part work.

Regards,
Santosh
