From: Michael Kerrisk <mtk.manpages@googlemail.com>
Subject: Re: [patch] add tcp congestion control relevant parts
Date: Wed, 02 Jan 2008 10:55:21 +0100
Message-ID: <477B5F89.9000707@gmail.com>
References: <476000E7.4060104@secunet.com>	<47624360.5050007@gmail.com> <20071214081540.4596bf21@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Kerrisk <mtk.manpages@googlemail.com>,
	netdev <netdev@vger.kernel.org>, linux-net@vger.kernel.org,
	Thomas Egerer <thomas.Egerer@secunet.com>,
	linux-man@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:1441 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753464AbYABJzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 04:55:50 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3120788fga.17
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2008 01:55:48 -0800 (PST)
In-Reply-To: <20071214081540.4596bf21@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Stephen Hemminger wrote:
> On Fri, 14 Dec 2007 09:48:32 +0100
> Michael Kerrisk <mtk.manpages@googlemail.com> wrote:
> 
>> Hello Linux networking folk,
>>
>> I received the patch below for the tcp.7 man page.  Would anybody here be
>> prepared to review the new material / double check the details?
>>
>> Cheers,
>>
>> Michael
>>
>> -------- Original Message --------
>> Subject: [patch] add tcp congestion control relevant parts
>> Date: Wed, 12 Dec 2007 16:40:23 +0100
>> From: Thomas Egerer <thomas.Egerer@secunet.com>
>> To: mtk.manpages@gmail.com
>> CC: linux-man@vger.kernel.org
>>
>> Hello *,
>>
>> man-pages version : 2.70 from http://www.kernel.org/pub/linux/docs/man-pages/
>> All required information were obtained by reading the kernel
>> code/documentation.
>> I'm not sure, whether it is completely bullet proof on when the sysctl
>> variables/socket option first appeared in the kernel, so you might as well
>> drop this information, but I'm pretty sure about how it works.
>> Here we go with my patch:
>>
>> diff -ru man-pages-2.70/man7/tcp.7 man-pages-2.70.new/man7/tcp.7
>> --- man-pages-2.70/man7/tcp.7   2007-11-24 14:33:34.000000000 +0100
>> +++ man-pages-2.70.new/man7/tcp.7       2007-12-12 16:34:52.000000000 +0100
>> @@ -177,8 +177,6 @@
>>  .\" FIXME As at Sept 2006, kernel 2.6.18-rc5, the following are
>>  .\"    not yet documented (shown with default values):
>>  .\"
>> -.\"     /proc/sys/net/ipv4/tcp_congestion_control (since 2.6.13)
>> -.\"     bic
>>  .\"     /proc/sys/net/ipv4/tcp_moderate_rcvbuf
>>  .\"     1
>>  .\"     /proc/sys/net/ipv4/tcp_no_metrics_save
>> @@ -224,6 +222,20 @@
>>  are reserved for the application buffer.
>>  A value of 0
>>  implies that no amount is reserved.
>> +.TP
>> +.BR tcp_allowed_congestion_control \
>> +" (String; default: cubic reno) (since 2.6.13) "
>> +Show/set the congestion control choices available to non-privileged
>> +processes. The list is a subset of those listed in
>> +.IR tcp_available_congestion_control "."
>> +Default is "cubic reno" and the default setting
>> +.RI ( tcp_congestion_control ).
>> +.TP
>> +.BR tcp_available_congestion_control \
>> +" (String; default: cubic reno) (since 2.6.13) "
>> +Lists the TCP congestion control algorithms available on the system. This
>> value
>> +can only be changed by loading/unloading modules responsible for congestion
>> +control.
>>  .\"
>>  .\" The following is from 2.6.12: Documentation/networking/ip-sysctl.txt
>>  .TP
>> @@ -257,6 +269,17 @@
>>  Allows two flows sharing the same connection to converge
>>  more rapidly.
>>  .TP
>> +.BR tcp_congestion_control " (String; default: cubic reno) (since 2.6.13) "
>> +Determines the congestion control algorithm used for newly created TCP
>> +sockets. By default Linux uses cubic with reno as fallback. If you want
>> +to have more control over the algorithm used, you must enable the symbol
>> +CONFIG_TCP_CONG_ADVANCED in your kernel config.
> 
> You can choose the default congestion control as well as part of the kernel
> configuration.

Hi Stephen,

Other than this, did the doc patch look okay?  (I'm not sure whether there
was an implied ACK in your message for the rest of the patch.)

Cheers,

Michael

-- 
Michael Kerrisk
Maintainer of the Linux man-pages project
http://www.kernel.org/doc/man-pages/
Want to report a man-pages bug?  Look here:
http://www.kernel.org/doc/man-pages/reporting_bugs.html


