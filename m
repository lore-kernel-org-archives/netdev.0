From: Ben Greear <greearb@candelatech.com>
Subject: Re: Testing interface removal speedup patches from Eric Dumazet.
Date: Mon, 09 May 2011 14:03:46 -0700
Message-ID: <4DC856B2.6050806@candelatech.com>
References: <4DC83471.7030701@candelatech.com> <06627C760FB049F1A9321BC6@Ximines.local> <4DC83A57.40405@candelatech.com> <D8B72070C6338973B87C9EFA@Ximines.local> <4DC843AF.6050607@candelatech.com> <39CEA2B6BDF36C1FA4B1EF64@nimrod.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52301 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247Ab1EIVD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 17:03:57 -0400
In-Reply-To: <39CEA2B6BDF36C1FA4B1EF64@nimrod.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2011 01:24 PM, Alex Bligh wrote:
> Ben,
>
> --On 9 May 2011 12:42:39 -0700 Ben Greear <greearb@candelatech.com> wrote:
>
>> I use HZ of 1000, btw.
>>
>> I killed udev, haldaemon..seemed to be just my stuff running.
>>
>> I don't see any 'ifup' running with these things dead...
>>
>> If you want to post your script, I can run it on my
>> machine...
>
> See below - run (on ubuntu) by
> service udev stop
> unshare -n bash
> ./ifseq -n 500
>
> The unshare seems sufficient to stop any remaining udev listeners getting
> wind of interface creation/deletion.

You were not adding the 'up' flag
on creation...and my script was.  I changed my script to not do
up and it reports similar numbers to yours...

Also, deleting with IPs added is likely to be a lot more work
than deleting w/out, as your script does.

Created 500 veth in 12.954143 seconds (0.025908286 per interface).
Added IP addresses in 28.35679 seconds (0.05671358 per addr).
Deleted 500 veth in 21.503877 seconds. (0.043007754 per interface)

Created 100 veth in 1.06471 seconds (0.0106471 per interface).
Added IP addresses in 2.006418 seconds (0.02006418 per addr).
Deleted 100 veth in 2.983303 seconds. (0.02983303 per interface)


 From your script:

[root@lec2010-ath9k-1 lanforge]# /mnt/b32/greearb/tmp/testifs.bash -n 500
Mon May 9 13:53:31 PDT 2011 creating 500 interfaces
Mon May 9 13:53:44 PDT 2011 done

real	0m12.756s
user	0m0.732s
sys	0m11.943s
Mon May 9 13:53:44 PDT 2011 deleting 500 interfaces
Mon May 9 13:54:02 PDT 2011 done

real	0m18.071s
user	0m1.002s
sys	0m8.376s
[root@lec2010-ath9k-1 lanforge]# /mnt/b32/greearb/tmp/testifs.bash -n 100
Mon May 9 13:54:33 PDT 2011 creating 100 interfaces
Mon May 9 13:54:34 PDT 2011 done

real	0m1.048s
user	0m0.092s
sys	0m0.943s
Mon May 9 13:54:34 PDT 2011 deleting 100 interfaces
Mon May 9 13:54:36 PDT 2011 done

real	0m2.219s
user	0m0.134s
sys	0m0.794s

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

