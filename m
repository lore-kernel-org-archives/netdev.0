From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: removing bridge in vlan_filtering mode requests delete of
 attached ports main MAC address
Date: Thu, 2 Nov 2017 18:22:53 +0900
Message-ID: <887be2d4-2684-3011-bf21-494f2ec6cb17@lab.ntt.co.jp>
References: <02874ECE860811409154E81DA85FBB5882ACC9A4@ORSMSX115.amr.corp.intel.com>
 <e48172b8-52ec-a9e8-c720-d9da69d8ced7@redhat.com>
 <02874ECE860811409154E81DA85FBB5882AD0E1A@ORSMSX115.amr.corp.intel.com>
 <02874ECE860811409154E81DA85FBB5882AD0E46@ORSMSX115.amr.corp.intel.com>
 <02874ECE860811409154E81DA85FBB5882AD8CF4@ORSMSX115.amr.corp.intel.com>
 <d1674dbe-a20d-bc08-3008-ffe312d84273@lab.ntt.co.jp>
 <02874ECE860811409154E81DA85FBB5882AD9C5D@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "vyasevic@redhat.com" <vyasevic@redhat.com>,
        "Malek, Patryk" <patryk.malek@intel.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:34225 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751767AbdKBJXX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 05:23:23 -0400
In-Reply-To: <02874ECE860811409154E81DA85FBB5882AD9C5D@ORSMSX115.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/11/02 7:25, Keller, Jacob E wrote:
...
>> If we skip adding them, we cannot receive frames which should be
>> received on the bridge device during non-promiscuous mode.
>>
>> --
>> Toshiaki Makita
> 
> This makes sense, but then what removes the addresses upon bridge deletion or exiting static mode?
> 
> We want to make sure we remove the correct addresses but don't request a delete of the permanent MAC address? Or, do we just completely assume that a device will never actually delete it's own permanent address, and thus say this is a driver's fault for allowing a delete request of its permanent address to do anything..?

We may be able to skip adding or deleting local address which is
identical to dev_addr in bridge code.
Having said that I feel like drivers should ensure not to remove their
permanent address even when the same address is removed from the uc
list, since currently it is not prohibited to do that kind of admin
operation through bridge command (bridge fdb add|del self).
Note that "bridge fdb ... self" is a command which modifies device's uc
filter, not modify bridge's fdb entries.

-- 
Toshiaki Makita
