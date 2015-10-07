From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4] net: ipv6: Make address flushing on ifdown
 optional
Date: Wed, 7 Oct 2015 11:01:53 -0600
Message-ID: <56155001.3070207@cumulusnetworks.com>
References: <1444231059-14830-1-git-send-email-dsa@cumulusnetworks.com>
 <CACP96tQtGecigUUHdF32w91qj=abqJLo+evzOL-9JakSJZ064A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, hannes@redhat.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34966 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995AbbJGRBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 13:01:51 -0400
Received: by pacfv12 with SMTP id fv12so27079877pac.2
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 10:01:51 -0700 (PDT)
In-Reply-To: <CACP96tQtGecigUUHdF32w91qj=abqJLo+evzOL-9JakSJZ064A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/15 9:43 AM, Sowmini Varadhan wrote:
> On Wed, Oct 7, 2015 at 11:17 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> Currently, all ipv6 addresses are flushed when the interface is configured
>> down, including global, static addresses:
>    :
>>
>> Add a new sysctl to make this behavior optional. The new setting defaults to
>> flush all addresses to maintain backwards compatibility. When the setting is
>> reset global addresses with no expire times are not flushed:
>
> does src addr selection also need to be modified to know if/when it can/cannot
> use this static address as a source addr? Or does the TENTATIVE flag
> make it Do The Right Thing per rfc 3484?
>

When the device is set 'down' (admin state) all routes (including cached 
ones) for the device are cleared so there should not be any way to 
select the source address that is saved. i.e, ipv6_dev_get_saddr() 
should not get invoked for the device.
