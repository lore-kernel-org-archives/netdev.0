From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 2/2] net: ovs: use CRC32 accelerated flow hash
 if available
Date: Fri, 13 Dec 2013 13:12:12 -0800
Message-ID: <CAEP_g=8R5T71tXOwW-s15jNsD5k2Pv6vD0JZEfEoAARC9BRZ_g@mail.gmail.com>
References: <1386860946-1621-1-git-send-email-ffusco@redhat.com>
 <1386860946-1621-3-git-send-email-ffusco@redhat.com> <CAEP_g=-JBT_XVvwSa4xOwVoTysoL0Z8zJc-ERSHJc96+qrA99Q@mail.gmail.com>
 <52AAD98B.7030100@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Thomas Graf <tgraf@redhat.com>
To: Francesco Fusco <ffusco@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:45988 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751507Ab3LMVMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 16:12:32 -0500
Received: by mail-ie0-f172.google.com with SMTP id qd12so3674195ieb.17
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 13:12:32 -0800 (PST)
In-Reply-To: <52AAD98B.7030100@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 1:55 AM, Francesco Fusco <ffusco@redhat.com> wrote:
> On 12/12/2013 09:20 PM, Jesse Gross wrote:
>>
>> Out of curiosity, did you try using crc32q? OVS data structures are
>> already aligned to 8 bytes. It would also be interesting to know if a
>> parallelized implementation is worthwhile, although my guess is that
>> the OVS flow key is not quite long enough.
>
>
> We did not try with crc32q yet because we had the very same concerns.
> In the general case, when the length of the key is not a multiple of 8
> bytes, we will have to use the crc32q to process multiple 64 bit numbers,
> then process the the rest with a crc32l. My guess is that the
> performance benefit won't be that high.

On 64-bit platforms, OVS already enforces alignment and multiples of 8
bytes for flow keys. If we introduced a hash primitive that does 8
bytes at a time instead of 4, there should be nothing extra to process
(although I don't know how big the upside would be).
