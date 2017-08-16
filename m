From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 11/12] igbvf: convert msleep to mdelay in atomic
 context
Date: Wed, 16 Aug 2017 10:58:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0056B76@AcuExch.aculab.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
 <20170809214746.28139-12-jeffrey.t.kirsher@intel.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0054ACD@AcuExch.aculab.com>
 <20170815193210.GC27768@psuche>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: 'Greg Edwards' <gedwards@ddn.com>,
        'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:61226 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751212AbdHPK6m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 06:58:42 -0400
In-Reply-To: <20170815193210.GC27768@psuche>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Edwards
> Sent: 15 August 2017 20:32
> On Mon, Aug 14, 2017 at 10:17:31AM +0000, David Laight wrote:
> > From: Jeff Kirsher
> >> Sent: 09 August 2017 22:48
> >> From: Greg Edwards <gedwards@ddn.com>
> >>
> >> This fixes a "scheduling while atomic" splat seen with
> >> CONFIG_DEBUG_ATOMIC_SLEEP enabled.
> >>
> >> Signed-off-by: Greg Edwards <gedwards@ddn.com>
> >> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> >> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >> ---
> >>  drivers/net/ethernet/intel/igbvf/vf.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/drivers/net/ethernet/intel/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
> >> index 1d3aa9adcaa8..9577ccf4b26a 100644
> >> --- a/drivers/net/ethernet/intel/igbvf/vf.c
> >> +++ b/drivers/net/ethernet/intel/igbvf/vf.c
> >> @@ -149,7 +149,7 @@ static s32 e1000_reset_hw_vf(struct e1000_hw *hw)
> >>  		msgbuf[0] = E1000_VF_RESET;
> >>  		mbx->ops.write_posted(hw, msgbuf, 1);
> >>
> >> -		msleep(10);
> >> +		mdelay(10);
> >
> > Spinning for 10ms seems somewhat sub-optimal
> 
> Jeff,
> 
> Do we even need this delay?  The subsequent read_posted() will poll for
> the PF's mailbox reply for up to 1s.

A 1 second loop?
Who is kidding who that this code is sensible.
If this code is ever executed and has to wait at all other interfaces
are likely to lose packets.

	David
