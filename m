From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] [v2] i40e: avoid 64-bit division where possible
Date: Fri, 20 Oct 2017 10:10:06 -0700
Message-ID: <CAKgT0UfryNBrMGdjOZjUyxucgkTv_5aYXCF1v3w8zOtjR2AxjA@mail.gmail.com>
References: <20171017155001.318184-1-arnd@arndb.de> <CAKgT0UfeDJomnen_2PhgnHSi27YROjTAtT=OYEj0JNVD8fzcOw@mail.gmail.com>
 <ae467f28-a972-dc2d-1bc8-e8ce4c7d9d68@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Arnd Bergmann <arnd@arndb.de>, Netdev <netdev@vger.kernel.org>,
        Mitch Williams <mitch.a.williams@intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>,
        Filip Sadowski <filip.sadowski@intel.com>,
        "David S. Miller" <davem@davemloft.net>
To: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ae467f28-a972-dc2d-1bc8-e8ce4c7d9d68@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2017 at 10:37 PM, Nambiar, Amritha
<amritha.nambiar@intel.com> wrote:
> On 10/17/2017 10:33 AM, Alexander Duyck wrote:
>> On Tue, Oct 17, 2017 at 8:49 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>>> The new bandwidth calculation caused a link error on 32-bit
>>> architectures, like
>>>
>>> ERROR: "__aeabi_uldivmod" [drivers/net/ethernet/intel/i40e/i40e.ko] undefined!
>>>
>>> The problem is the max_tx_rate calculation that uses 64-bit integers.
>>> This is not really necessary since the numbers are in MBit/s so
>>> they won't be higher than 40000 for the highest support rate, and
>>> are guaranteed to not exceed 2^32 in future generations either.
>>>
>>> Another patch from Alan Brady fixed the link error by adding
>>> many calls to do_div(), which makes the code less efficent and
>>> less readable than necessary.
>>>
>>> This changes the representation to 'u32' when dealing with MBit/s
>>> and uses div_u64() to convert from u64 numbers in byte/s, reverting
>>> parts of Alan's earlier fix that have become obsolete now.
>>>
>
> This patch breaks the functionality while converting the rates in
> bytes/s provided by tc-layer into the Mbit/s in the driver.
> I40E_BW_MBPS_DIVISOR defined in Alan's patch should be used for the
> conversion, and not I40E_BW_CREDIT_DIVISOR which does the incorrect
> math. I40E_BW_CREDIT_DIVISOR is in place because the device uses credit
> rates in values of 50Mbps.

Can we get the patch that was applied to the tree pulled? The patch
itself contained some bugs as Amritha had pointed out, but it looks
like there was some sort of merge conflict or something and now I
cannot get the tree to build without having to revert the patch since
somehow the code around i40e_rebuild_channels changed and is now
throwing errors because "credits" wasn't replaced and is still
accessed in the dev_dbg command.

- Alex
