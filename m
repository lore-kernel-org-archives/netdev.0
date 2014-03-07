From: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Subject: Re: [PATCHv2 3/5] net: rfkill: gpio: remove gpio names
Date: Thu, 06 Mar 2014 21:22:23 -0700
Message-ID: <5319497F.9080003@wwwdotorg.org>
References: <1393330950-7283-1-git-send-email-heikki.krogerus@linux.intel.com> <1393330950-7283-4-git-send-email-heikki.krogerus@linux.intel.com> <530D218E.9010007@wwwdotorg.org> <CACRpkdZF4-rWs1WkOp3t0x77fgSCE71E=wdrxiDuGZ8eBu_p_Q@mail.gmail.com> <53168976.7000008@wwwdotorg.org> <CACRpkdYfQoDmPX0He4J2Sn2wgQn2hHoHyPqnStLRVqrvi=M+-w@mail.gmail.com> <53169304.9080002@wwwdotorg.org> <CACRpkdaYuZ5bXo7djOv04oyHPAFbO=pKfR7L7UBY+kZqZUHfmQ@mail.gmail.com> <CAGb2v65UQZoDJhjpX+kfa6HppXdhrCHG=A5m_WaQ_DimW-Lsbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Rhyland Klein <rklein-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
	Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGb2v65UQZoDJhjpX+kfa6HppXdhrCHG=A5m_WaQ_DimW-Lsbg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/06/2014 08:43 PM, Chen-Yu Tsai wrote:
> On Fri, Mar 7, 2014 at 11:41 AM, Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
>> On Wed, Mar 5, 2014 at 10:59 AM, Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org> wrote:
>>> On 03/04/2014 07:37 PM, Linus Walleij wrote:
>>>> On Wed, Mar 5, 2014 at 10:18 AM, Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org> wrote:
>>>>> On 03/04/2014 06:43 PM, Linus Walleij wrote:
>>>>
>>>>>> If I understand the situation correctly it's like ACPI does not have named
>>>>>> GPIOs so keeping specifying this in DT GPIO bindings is counter-productive
>>>>>> to the work of abstracting the access to GPIO handlers so that drivers
>>>>>> need not know whether ACPI or DT is used for describing the hardware.
>>>>>
>>>>> For devices that already have both ACPI and DT bindings, we can't
>>>>> pretend they can be the same; they are already potentially different. We
>>>>> simply need to parse DT and ACPI differently, since that's the sway
>>>>> their bindings are defined.
>>>>>
>>>>> For any devices that don't have both ACPI and DT bindings, I agree we
>>>>> should certainly strive to make any new bindings aligned so we don't
>>>>> have to deal with this for them.
>>>>>
>>>>> However, we can't change the past.
>>>>
>>>> Yeah, right, so for this very driver there are no bindings defined (yet)
>>>> and the only device tree I can find referencing it is the Tegra20-paz00
>>>> and it just use gpios = <>;
>>>>
>>>> So in this case I think this patch is the right way forward, but I admit
>>>> I'm really uncertain in the general case.
>>>
>>> If there are no bindings defined at all yet, then we can define both DT
>>> and ACPI bindings to use name-based GPIOs. Index-based lookups aren't a
>>> good way forward.
>>
>> After Mark clarifying that ACPI is going to have named GPIOs I'm
>> totally aligned on this, so OK!
> 
> Glad to hear this, but is it possible to get rid of the index in current
> drivers? Or change the behavior to name-based OR index-based lookups.
> This might break any DTs that have multiple GPIOs defined under one
> property though.

For any bindings that are already defined to use index-based lookups, I
think we have to continue using them, for backwards-compatibility with
old DTs (and I assume old ACPI databases need the same thing).
