From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.8.4 kernel
Date: Tue, 07 May 2013 10:11:56 -0700
Message-ID: <1367946716.13473.9.camel@edumazet-glaptop>
References: <5153620E.4010608@gmail.com>
	 <CAErSpo6w+tTbwJ7Qinpd0Vx20q5cm2gMvqzE1Do+2=G3b8rcHA@mail.gmail.com>
	 <CAErSpo6iwM2r8b-aoiBPjQpkdpcfgLiO+WkpiM1wFsDhxuSXPg@mail.gmail.com>
	 <CAErSpo68AWCGWQHKgoKuD-QFA0b+jbCRf7T_PzzKoUsVwdZHOg@mail.gmail.com>
	 <157393863283F442885425D2C45428564F219B3B@nasanexd02f.na.qualcomm.com>
	 <CAErSpo44-f4UdXxO5MdwVg09LFABwFQ320gG8v8jHcYh=5gqvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Huang, Xiong" <xiong@qca.qualcomm.com>,
	"Joseph A. Millikan" <josephamillikan@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ren, Cloud" <cjren@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Bjorn Helgaas <bhelgaas@google.com>,
	Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAErSpo44-f4UdXxO5MdwVg09LFABwFQ320gG8v8jHcYh=5gqvA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-07 at 09:20 -0700, Bjorn Helgaas wrote:
> [+cc Eric because he made a change (69b08f62e17) that apparently
> exposes driver bugs]
> 
> On Mon, May 6, 2013 at 7:51 PM, Huang, Xiong <xiong@qca.qualcomm.com> wrote:
> >> >
> >> > Did this ever get resolved?
> >>
> >> I opened https://bugzilla.kernel.org/show_bug.cgi?id=57681 to keep track of
> >> this and attached the dmesg logs you collected.  If you have a chance, could you
> >> also collect and attach the output of "lspci -vv"
> >> (any kernel is fine for this).
> >>
> >> I don't see anything obvious wrong, at least from the PCI side.  Maybe the atl1c
> >> guys will have some ideas.
> >>
> >
> > Hi Bjorn and All
> >      This issue should be same as bug https://bugzilla.kernel.org/show_bug.cgi?id=54021
> >      I didn't find any abnormal info from the log and the PHY link is stable as well :(
> >      Is it related to the network manager ?
> 
> I looked at bug #54021 and it does look similar.  It doesn't look like
> it has been resolved.
> 
> http://forums.gentoo.org/viewtopic-t-949168-highlight-.html is another
> report that looks very similar.  BigE there has a Lenovo G570 that has
> both wireless and wired networking.  If BigE disables wireless with a
> hardware switch before booting, it seems to avoid the atl1c wired
> networking issue.  That's not a fix, of course, but it might be a clue
> and a temporary workaround until we have a real solution.
> 
> Joseph, if there's no hardware switch for the wireless on your G770,
> you can probably still take wireless out of the picture by removing or
> renaming the bcma module (look in
> /lib/modules/.../kernel/drivers/bcma/), then rebooting.
> 
> Xiong, do you have a specific network manager-related test that Joseph
> could perform?  I don't want to burden Joseph with a lot of debugging
> because he's currently happy with 3.6.11 and testing is pretty
> disruptive in his environment.

drivers/net/wireless/brcm80211/brcmsmac/dma.c contains this suspect code
in dma64_getnextrxp() :

dma_addr_t pa;
...
pa = le32_to_cpu(di->rxd64[i].addrlow) - di->dataoffsetlow;
/* clear this packet from the descriptor ring */
dma_unmap_single(di->dmadev, pa, di->rxbufsize, DMA_FROM_DEVICE);


How can it possibly work, I honestly have no idea.

I suggest enabling CONFIG_DMA_API_DEBUG ?
