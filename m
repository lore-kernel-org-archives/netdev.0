From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH 3/3] net: dsa: exit probe if no switch were found
Date: Fri, 02 Oct 2015 10:39:32 -0700
Message-ID: <560EC154.8060400@gmail.com>
References: <560B9B7C.9080406@baylibre.com> <560D50E4.6040400@baylibre.com> <20151001163257.GQ20219@lunn.ch> <560E744E.4010502@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560E744E.4010502@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/10/15 05:10, Neil Armstrong wrote:
> On 10/01/2015 06:32 PM, Andrew Lunn wrote:
>> On Thu, Oct 01, 2015 at 05:27:32PM +0200, Neil Armstrong wrote:
>>> On 09/30/2015 10:21 AM, Neil Armstrong wrote:
>>>> If no switch were found in dsa_setup_dst, return -ENODEV and
>>>> exit the dsa_probe cleanly.
>>
>> ...
>>  
>>> Couldn't we use the probe defer mechanism here ? (until complete rework is done)
>>
>> Hi Neil
>>
>> I was thinking the same last night. We know the switch should be
>> there, otherwise it would not be in DT. So returning -EPROBE_DEFER
>> would be valid.
>>
>>       Andrew
>>
> Hi,
> 
> It makes sens but does a module insertion triggers the differed probe ?

That's a good question, I am not convinced this is the case. Even with
the EPROBE_DEFER returned if the list of drivers is empty, you would
still very likely run into the following circular dependency, if you
make everything built as a module:

- dsa provides register_switch_driver and unregister_switch_driver
- switch drivers in drivers/net/dsa/* depend on these two symbols, so
until these symbols are loaded, the module loader cannot complete their
load successfully
- dsa will not be able to make any progress, that is, its driver list
will be empty as long as no switch driver is loaded

If you build dsa into your kernel, you might be fine though, or in a
better shape at least.
-- 
Florian
