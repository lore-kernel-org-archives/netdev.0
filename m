From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH RFC] iw_cxgb3: Support "iwarp-only" interfaces to avoid
 4-tuple conflicts with the host stack.
Date: Wed, 05 Sep 2007 12:27:09 -0500
Message-ID: <46DEE6ED.7070000@opengridcomputing.com>
References: <1187905185.5547.13.camel@stevo-desktop>	<adaveawwcpz.fsf@cisco.com> <46DD762F.80904@opengridcomputing.com> <ada642puonr.fsf@cisco.com> <46DECDED.90903@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sean.hefty@intel.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([71.42.183.126]:45414 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752442AbXIER1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 13:27:10 -0400
In-Reply-To: <46DECDED.90903@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Steve Wise wrote:
> 
> 
> Roland Dreier wrote:
>>  > > What's wrong with my suggestion of having the iwarp driver create an
>>  > > "iwX" interface to go with the normal "ethX" interface?  It seems
>>  > > simpler to me, and there's a somewhat similar precedent with how
>>  > > mac80211 devices create both wlan0 and wmaster0 interfaces.
>>  > >  - R.
>>  >  > It seemed much more painful for me to implement. :-)
>>  >  > I'll look into this, but I think for this to be done, the 
>> changes must
>>  > be in the cxgb3 driver, not the rdma driver, because the guts of the
>>  > netdev struct are all private to cxgb3.  Remember that this interface
>>  > needs to still do non TCP traffic (like ARP and UDP)...
>>  >  > Maybe you have something in mind here that I'm not thinking about?
>>
>> No, I was just spouting off.
>>
> 
> At least someone is looking at my patch. ;-)
> 
>> But the whole "create a magic alias" seems kind of unfriendly to the
>> user.  Maybe as you said, the cxgb3 net driver could create the alias
>> for the iw_cxgb3 driver?
> 
> I agree that it is not very user friendly.
> 
> My current patch just utilizes the IP address alias logic in the IP 
> stack.  So when you do 'ifconfig ethxx:blah ipaddr up' it creates a 
> struct in_ifaddr which contains a ptr to the real struct net_device that 
> services this alias.  However, from what I can tell, I cannot just 
> create one of these without binding an address.  So the driver cannot 
> create the alias interface until it knows the ipaddr/netmask/etc.  IE: 
> if you say 'ifconfig ethxx:blah up' it fails...  You must supply an 
> address to get one of these created.
> 
> To have the cxgb3 driver create something like 'iw0', I think it would 
> need to create a full net_device struct.  This makes the change much 
> more complex.  But perhaps its the right thing to do...
> 
> Steve.
> 

Also, I could defer registering the device with the rdma core until the 
alias interface is created by the user.  Thus the T3 device wouldn't be 
available for use until the ethxx:iw interface is created.

And I could log a WARN or INFO message if the iw_cxgb3 module is loaded 
and no ethxx:iw alias exists.  This would help clue in the user...

Steve.


