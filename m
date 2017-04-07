From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [BUG] kernel oops during bridge creation
Date: Fri, 7 Apr 2017 11:36:22 +0300
Message-ID: <e1385d3b-19c9-d6d4-b2ea-4be42fa4a1e3@cumulusnetworks.com>
References: <4d4b58e0-06e5-de5a-3305-abc739cf2ba2@svinota.eu>
 <20170406185814.GA21480@splinter>
 <adc7b0d6-68b9-6649-73fc-f5e82812f4a6@cumulusnetworks.com>
 <20170406204452.GA24938@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Peter V. Saveliev" <peter@svinota.eu>, netdev@vger.kernel.org,
        Ivan Vecera <ivecera@redhat.com>
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:32875 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754291AbdDGIgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 04:36:25 -0400
Received: by mail-wr0-f172.google.com with SMTP id g19so52878855wrb.0
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 01:36:25 -0700 (PDT)
In-Reply-To: <20170406204452.GA24938@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/17 23:44, Ido Schimmel wrote:
> On Thu, Apr 06, 2017 at 11:26:06PM +0300, Nikolay Aleksandrov wrote:
>> Actually making br_vlan_init() idempotent might work, keep the code as-is just init the
>> the vlans before the changelink() in newlink(), then the second vlan_init() inside would
>> be a no-op, but it will work for the old ioctl and wouldn't require too much change.
>> On the downside it will be ugly.
> 
> Yep, that can work. I'll try that tomorrow morning and let you know.
> 
> Thanks Nik!
> 

Great, thanks, just one more thing to keep in mind. The vlan add would try
to add the bridge mac address which in turn will generate a notification
with ifindex = 0 since it will get assigned during register_netdevice() later.

The only way to get correct behaviour seems to make the changelink() opportunistic
and move it after the netdevice_register(), though that may cause a device which
is half configured if something's wrong with the config, but the good thing with
the bridge is that everything can be set during runtime so no need to destroy/make
it again.
