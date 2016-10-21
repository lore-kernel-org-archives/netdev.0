From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Fri, 21 Oct 2016 11:43:34 +1100
Message-ID: <20161021114334.1eb189aa@canb.auug.org.au>
References: <20161021092710.1b56a35b@canb.auug.org.au>
        <bd2fa038-2d0a-8cd1-d80d-860a7497bdf5@gmail.com>
        <e2380249-29b4-4769-514a-5fc5fbd8f95c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e2380249-29b4-4769-514a-5fc5fbd8f95c@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Thu, 20 Oct 2016 17:30:33 -0700 Florian Fainelli <f.fainelli@gmail.com> wrote:
>
> On 10/20/2016 03:42 PM, Florian Fainelli wrote:
> > On 10/20/2016 03:27 PM, Stephen Rothwell wrote:  
> >>
> >> After merging the net tree, today's linux-next build (arm
> >> multi_v7_defconfig) failed like this:
> >>
> >> ERROR: "kexec_in_progress" [drivers/net/dsa/bcm_sf2.ko] undefined!
> >>
> >> Caused by commit
> >>
> >>   2399d6143f85 ("net: dsa: bcm_sf2: Prevent GPHY shutdown for kexec'd kernels")
> >>
> >> I used the version of the net tree from next-20161020 for today.  
> > 
> > OK, seems like we need an ifdef CONFIG_KEXEC_CORE, let me fix that.
> > Thanks Stephen!  
> 
> Stephen, can you send me the .config file? I could not reproduce it with
> next-20161020 and doing a make multi_v7_defconfig:

This only started with the net tree as of today (HEAD a681574c99be).
The problem is simply that kexec_in_progress is not exported to modules.

Sorry, getting the actual .config file is a pain at this point since my
builds have moved on.

It probably had (the current .config has):

CONFIG_NET_DSA_BCM_SF2=m
CONFIG_KEXEC_CORE=y

If CONFIG_KEXEC_CORE is not set, then kexec_in_progress is defined to false.

-- 
Cheers,
Stephen Rothwell
