From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] kexec: Export kexec_in_progress to modules
Date: Fri, 21 Oct 2016 11:48:24 -0700
Message-ID: <441f79c2-fcf3-b35b-f30d-3667513a51c0@gmail.com>
References: <1477012516-20470-1-git-send-email-f.fainelli@gmail.com>
 <20161020.215410.650162338407203719.davem@davemloft.net>
 <871szagtls.fsf@xmission.com>
 <20161021.101343.1389577512803674816.davem@davemloft.net>
 <87wph1eeft.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kexec@lists.infradead.org,
        linux-kernel@vger.kernel.org, sfr@canb.auug.org.au
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87wph1eeft.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2016 11:37 AM, Eric W. Biederman wrote:
> David Miller <davem@davemloft.net> writes:
> 
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Fri, 21 Oct 2016 00:26:55 -0500
>>
>>> So as far as I can tell you are advocating for a change to support a
>>> driver doing something that is completely pointless.  So no let's not
>>> export this symbol.  Please fix the driver to do something less
>>> pointless instead.
>>
>> FLorian explained his reasoning for doing what he is doing in this
>> specific driver and it made sense to me.
> 
> What doesn't make sense to me is not doing that for any other kind of
> reboot.
> 
> Of the 3 uses of kexec_in_progres in the kernel (not counting this one)
> I think there is only one of them that is really valid.   And that one
> is only valid because it is the least horrible thing the pci layer can
> do.  (AKA it is a hack even there).
> 
> It really is nonsense having methods do different things depending on
> context and that is why kexec_in_progress is not exeported.
> 
> As far as I can tell the use of kexec_in_progress winds up being
> a fragile hack that will just cause more problems later on.
> 
> Florian is there a good readon why you don't just do?

Checking kexec_in_progress allowed not to turn the PHY on for a normal
reboot case, since we don't necessarily know when it will be
re-initialized next, so in that sense it's a power optimization that is
nice to have.

> 
> static void bcm_sf2_sw_shutdown(struct platform_device *pdev)
> {
>         struct bcm_sf2_priv *priv = platform_get_drvdata(pdev);
> 
> 	/* For a kernel about to be kexec'd we want to keep the GPHY on for a
>          * successful MDIO bus scan to occur. If we did turn off the GPHY
> 	 * before (e.g: port_disable), this will also power it back on.
> 	 */
> 	if (priv->hw_params.num_gphy == 1)
> 		bcm_sf2_gphy_enable_set(priv->dev->ds, true);
> }
> 
> I certainly don't see anything in the changelog to explain why that
> isn't done.

That would result in an identical behavior for what I am after, David,
shall I send a revert plus this?
-- 
Florian
