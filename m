From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 15:18:37 -0700
Message-ID: <4706B83D.40306@sun.com>
References: <20071005.031209.57156822.davem@davemloft.net>
 <200710051846.19965.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ariel.Hendel@Sun.COM, Greg.Onufer@Sun.COM, jeff@garzik.org,
	Ashley.Saulsbury@Sun.COM
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:60734 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760636AbXJEWSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 18:18:36 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id l95MIaVO029791
	for <netdev@vger.kernel.org>; Fri, 5 Oct 2007 15:18:36 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JPG00001LU7SV00@fe-sfbay-10.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Fri,
 05 Oct 2007 15:18:36 -0700 (PDT)
In-reply-to: <200710051846.19965.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser wrote:
> Hi David,

Repost since my last post ended up being html
Regards,

matheos

> 
> some minor nits.

Some  Neptune HW  info to explain some of the constants ...

> 
> Could this driver be split into more files. 8k lines per file

>> +	case 0:
>> +		ctrl_reg = ENET_SERDES_0_CTRL_CFG;
>> +		test_cfg_reg = ENET_SERDES_0_TEST_CFG;
>> +		break;
>> +	case 1:
>> +		ctrl_reg = ENET_SERDES_1_CTRL_CFG;
>> +		test_cfg_reg = ENET_SERDES_1_TEST_CFG;
>> +		break;
>> +
>> +	default:
>> +		return -EINVAL;
>> +	}
> 
> 
> Maybe small table?
> 
>> +	ctrl_val = (ENET_SERDES_CTRL_SDET_0 |
>> +		    ENET_SERDES_CTRL_SDET_1 |
>> +		    ENET_SERDES_CTRL_SDET_2 |
>> +		    ENET_SERDES_CTRL_SDET_3 |
>> +		    (0x5 << ENET_SERDES_CTRL_EMPH_0_SHIFT) |
>> +		    (0x5 << ENET_SERDES_CTRL_EMPH_1_SHIFT) |
>> +		    (0x5 << ENET_SERDES_CTRL_EMPH_2_SHIFT) |
>> +		    (0x5 << ENET_SERDES_CTRL_EMPH_3_SHIFT) |
>> +		    (0x1 << ENET_SERDES_CTRL_LADJ_0_SHIFT) |
>> +		    (0x1 << ENET_SERDES_CTRL_LADJ_1_SHIFT) |
>> +		    (0x1 << ENET_SERDES_CTRL_LADJ_2_SHIFT) |
>> +		    (0x1 << ENET_SERDES_CTRL_LADJ_3_SHIFT));
>> +	test_cfg_val = 0;
>> +
>> +	if (lp->loopback_mode == LOOPBACK_PHY) {
>> +		test_cfg_val |= ((ENET_TEST_MD_PAD_LOOPBACK <<
>> +				  ENET_SERDES_TEST_MD_0_SHIFT) |
>> +				 (ENET_TEST_MD_PAD_LOOPBACK <<
>> +				  ENET_SERDES_TEST_MD_1_SHIFT) |
>> +				 (ENET_TEST_MD_PAD_LOOPBACK <<
>> +				  ENET_SERDES_TEST_MD_2_SHIFT) |
>> +				 (ENET_TEST_MD_PAD_LOOPBACK <<
>> +				  ENET_SERDES_TEST_MD_3_SHIFT));
>> +	}
>> +
>> +	nw64(ctrl_reg, ctrl_val);
>> +	nw64(test_cfg_reg, test_cfg_val);
>> +
>> +	for (i = 0; i < 4; i++) {
> 
> why 4? (magic number)

The MAC HW has 4 SERDES lanes. Need to configure each lane.

> 
>> +		u32 rxtx_ctrl, glue0;
>> +		int err;
>> +
>> +		err = esr_read_rxtx_ctrl(np, i, &rxtx_ctrl);
>> +		if (err)
>> +			return err;
>> +		err = esr_read_glue0(np, i, &glue0);

>> +
> 

> 
> [...]
> 
>> +static void niu_set_max_burst(struct niu *np, struct tx_ring_info *rp)
>> +{
>> +	int mtu = np->dev->mtu;
>> +
>> +	rp->max_burst = mtu + 32;
>> +	if (rp->max_burst > 4096)
>> +		rp->max_burst = 4096;
> 
> Why 32 and 4096? (Magic values)

These values were recommended by the HW designers for fair utilization 
of DRR feature among TX/RX rings.

> 
>> +}
>> +
> 
> ... ok, I stop here, since this drivers is damn big :-)
> 
> Best Regards
> 
> Ingo Oeser

