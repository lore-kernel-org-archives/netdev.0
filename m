From: Robert Vineyard <vineyard@tuffmail.com>
Subject: Re: [Question]About KVM network zero-copy  feature!
Date: Sun, 12 Aug 2012 23:45:27 -0400
Message-ID: <50287857.2060305@tuffmail.com>
References: <50248148.4070204@huawei.com>
	<20120811135556.58ddf48d@nehalam.linuxnetplumber.net>
	<5026D49B.10305@tuffmail.com> <5026FC04.6080108@tuffmail.com>
	<20120812093730.GD1421@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	"Peter Huang\(Peng\)" <peter.huangpeng@huawei.com>,
	virtualization@lists.linux-foundation.org, avi@redhat.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120812093730.GD1421@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 08/12/2012 05:37 AM, Michael S. Tsirkin wrote:
> AFAIK Xin left Intel and is not working on it.
> Contributions are welcome.

That's too bad... do you know of anyone else (at Intel or otherwise) who 
might be familiar enough with the existing codebase to get me started?

 From the code I've looked at, it appears that among other things 
they're using the splice(2) / vmsplice(2) system calls to effect 
"copying" without actually copying data. If I understand the semantics 
correctly, these calls are basically shuffling pointers around to avoid 
unnecessary memcpy(3) / mmap(2) calls. I've even seen a "zero-copy" 
version of sendfile(2) that essentially wraps it around a call to splice(2).

I may be able to hack something together based on the current zero-copy 
TX implementation, but as I'm still wrapping my head around several of 
the concepts I just described, it may be awhile before I can produce 
anything useful. I have quite a bit of experience developing for Linux 
in C, but this would be my first attempt at writing kernel/device-driver 
code.

>> The Release Notes for RHEL 6.2 (originally published on 12/06/2011)
>> also specifically mention macvtap/vhost zero-copy capabilities as
>> being included as a Technology Preview:
>>
>> http://docs.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/6/html/6.2_Release_Notes/virtualization.html
>
> I think this means TX.

It does. I meant to clarify that point in my original email... yes, only 
TX zero-copy is currently implemented, and it is still marked as 
"experimental". Outside of the custom solutions like PF_RING that I 
mentioned, I don't know that I've seen zero-copy for RX.

-- Robert Vineyard
