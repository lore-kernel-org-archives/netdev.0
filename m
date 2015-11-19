From: Florian Weimer <fweimer@redhat.com>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Thu, 19 Nov 2015 10:39:36 +0100
Message-ID: <564D98D8.9050000@redhat.com>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag>
 <564CEB0C.40006@redhat.com> <564CEC65.4080901@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stefan Priebe <s.priebe@profihost.ag>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564CEC65.4080901@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/18/2015 10:23 PM, Stefan Priebe wrote:

>> please try to get a backtrace with debugging information.  It is likely
>> that this is the make_request/__check_pf functionality in glibc, but it
>> would be nice to get some certainty.
>>
>> Which glibc version do you use?  Has it got a fix for CVE-2013-7423?
> 
> It's Debians 2.13-38+deb7u8 Debians issue tracker says it is fixed:
> https://security-tracker.debian.org/tracker/CVE-2013-7423

I checked, and the patch is there and applied.

>> Theoretically, recvmsg could also hang if the Netlink query was dropped
>> by the kernel, or the final packet in the response was dropped.  We
>> never saw that happen, even under extreme load, but I didn't test with
>> recent kernels.
> 
> The load is very low in this system. Just 30 phones and only 1-6 calling.

This is rather odd.

I'm not sure if we can do anything simple on the glibc to help to debug
this.  If something in the process consumes the Netlink message from the
kernel (incorrectly reading from the internal glibc file descriptor),
this is fairly difficult detect inside glibc (it would require rather
large changes which do not currently exist at all).

Florian
