From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH RFC]: e1000: allow VLAN devices to use TSO and CSUM offload
Date: Fri, 10 Oct 2008 10:50:07 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5206672441@orsmsx418.amr.corp.intel.com>
References: <487DC7DB.70401@trash.net> <48EF690F.5070105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <e1000-devel@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Patrick McHardy" <kaber@trash.net>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51353 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758822AbYJJRyy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 13:54:54 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> Patrick McHardy wrote:
>> Patrick McHardy wrote:
>>> This patch changes e1000 to set vlan_features so TSO and CSUM
>>> offload can be used by VLAN devices, similar as with the other
>>> Intel drivers. 
>>> 
>>> Only RFC because I don't know whether there is buggy hardware
>>> that doesn't support this properly, but feel free to apply in
>>> case there isn't.
>> 
>> I never received a response to this. Any comments?
> 
> Sorry to delay the reply, the only one that stands out to me as a
> possible problem with the devices that e1000 still supports is the
> NETIF_F_TSO6.  
> 
> I know that some of our older parts like 82544 don't support TSO6.
> 
> As I read: these should work:
> 82546GB/EB, 82545GM/EM, 82541(PI/GI/EI), 82541ER, 82547GI/EI, and
> 82540EP/EM 
> 
> These parts should all work (at least as advertised in the software
> reference manual available at
>
http://superb-east.dl.sourceforge.net/sourceforge/e1000/OpenSDM_8254x-37
.pdf)
> 
> with the exception of 82544 GC/EI
> 
> So as it stands your patch will not work on some hardware.  Also,
> would we need to hook the ethtool methods such that if a user
> disables TSO it will disable vlan_features(TSO) as well?  

Oh, and the 82542 and 82543 based parts don't do this either, they
aren't covered by the manual above.
