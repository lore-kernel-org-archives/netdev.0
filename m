From: vincent Richard <vincent.richard449@gmail.com>
Subject: Re: bnx2x multicast packet loss on igmp join/leave
Date: Fri, 5 Apr 2013 15:06:48 +0200
Message-ID: <CABVbdp8qoUWhoUFDvVo-4pSkbGrGCYaqxhJPB6hDAW2_1B_CKw@mail.gmail.com>
References: <CABVbdp_R7H5tWfFUF_8c=4GWLC80Vr8SajZskc8C51Hduue49Q@mail.gmail.com>
	<CAM8tLiMrMtrqzZKPK+65UFoojcAfWBeeBTWhsU7ALtaOSozwLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Kravkov <dkravkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f54.google.com ([209.85.128.54]:49142 "EHLO
	mail-qe0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161348Ab3DENGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 09:06:49 -0400
Received: by mail-qe0-f54.google.com with SMTP id s14so1994443qeb.13
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 06:06:48 -0700 (PDT)
In-Reply-To: <CAM8tLiMrMtrqzZKPK+65UFoojcAfWBeeBTWhsU7ALtaOSozwLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/4/5, Dmitry Kravkov <dkravkov@gmail.com>:
> On Fri, Apr 5, 2013 at 1:13 PM, vincent Richard
> <vincent.richard449@gmail.com> wrote:
>>
>> I all,
>>
>> I am using a HP server with bnx2x ethernet cards in it.
>> I have compiled the latest linux 3.2 version, and I am encountering
>> the following error :
>>
>> when joining or leaving a multicast group, other multicast streams
>> lose some packets.
>>
>> I tried latest firmware and different drivers (latest HP recommended
>> one (redhat one)) but still the same..
>>
>> I observe that putting the interface in promiscuous mode make the
>> problem disappear.
>>
>> looking around bnx2x_set_rx_mode, i notice that there is 3 rx_mode,
>> NORMAL, PROMISCUOUS and ALLMULTI . forcing other than normal mode
>> correct my issue..
>>
>> My bnx2x is in a blade center so there is a switch just after. So
>> forcing PROMISCUOUS or ALLMULTI mode have no major impact.
>>
>> To reproduce the problem I just "listen" 2 multicast streams and
>> join/leave another one periodically.
>>
>> Thanks in advance for your help.
>> Regards,
>> Vincent
>
> This because on MC group change, bnx2x first removes the devices from
> ALL MC groups and then
> add the device to newly configured groups:
>
> 11112        /* first, clear all configured multicast MACs */
> 11113        rc = bnx2x_config_mcast(bp, &rparam, BNX2X_MCAST_CMD_DEL);
> 11114        if (rc < 0) {
> 11115                BNX2X_ERR("Failed to clear multicast
> configuration: %d\n", rc);
> 11116                return rc;
> 11117        }
> 11118
> 11119        /* then, configure a new MACs list */
> 11120        if (netdev_mc_count(dev)) {
> 11121               rc = bnx2x_init_mcast_macs_list(bp, &rparam);
>


Thanks for the quick answer, BTW I am very surprised of this behavior.
It is the first time I encounter (or see) this.
