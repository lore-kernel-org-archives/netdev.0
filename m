From: James Chapman <jchapman@katalix.com>
Subject: Re: unmanaged L2TPv3 ethernet pseudowire Cisco <=> Linux
Date: Wed, 27 Mar 2013 20:56:54 +0000
Message-ID: <51535D16.4080207@katalix.com>
References: <Pine.LNX.4.61.1303241153000.20041@envy.nxs.se> <CAEwTi7Rbo3dBqhyDJXYvrkMWfrX9xwUr5VovFoW7BfPAZp4XFw@mail.gmail.com> <Pine.LNX.4.61.1303272104470.20041@envy.nxs.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tomas Agartz <tlund@nxs.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36474 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841Ab3C0U45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 16:56:57 -0400
In-Reply-To: <Pine.LNX.4.61.1303272104470.20041@envy.nxs.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/03/13 20:08, Tomas Agartz wrote:
> On Tue, 26 Mar 2013, James Chapman wrote:
> 
>> The issue is that Linux and Cisco use a different default for the
>> L2SpecificSublayer header setting and neither implementation provides
>> a config option to change its setting. :-( The Linux default is to use
>> the Default L2SpecificSublayer as defined in the RFC. Unfortunately
>> the Cisco default is to use no L2SpecificSublayer.
>>
>> The kernel already has an API to allow the L2SpecificSublayer setting
>> to be configured. The missing piece is an iproute2 l2tp config option
>> to configure it. I'll work on an iproute2 patch now to allow this
>> setting to be configured.
> 
> I patched my iproute2 with your patch and now my tunnel is working.
> Thank you! :)

Great. Thanks for reporting back.

>> For unmanaged tunnels, these parameters must be manually configured
>> consistently at each side. Both Cisco and Linux default to use no
>> cookies and both already have config parameters to set cookie
>> parameters, if needed. However, for L2SpecificSublayer this isn't the
>> case. We need to add a config option on the Linux side to force the
>> same setting as Cisco is using.
> 
> Does the API in the kernel allow you to set the cookie? In that case it
> seems like a good idea to add that to iproute2 as well?

It is already supported. See the cookie and peer_cookie parameters of ip
l2tp add session.

ip l2tp help
or
man ip-l2tp

James
