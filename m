From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 6/6] vhost_net: don't poll on -EFAULT
Date: Tue, 17 Apr 2012 11:27:01 +0800
Message-ID: <4F8CE305.9090100@redhat.com>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com> <20120416060833.14140.28139.stgit@intel-e5620-16-2.englab.nay.redhat.com> <20120416071646.GB25396@redhat.com> <4F8BD81A.7010507@redhat.com> <20120416133859.GB13190@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xma@us.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120416133859.GB13190@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/16/2012 09:39 PM, Michael S. Tsirkin wrote:
> On Mon, Apr 16, 2012 at 04:28:10PM +0800, Jason Wang wrote:
>> >  On 04/16/2012 03:16 PM, Michael S. Tsirkin wrote:
>>> >  >On Mon, Apr 16, 2012 at 02:08:33PM +0800, Jason Wang wrote:
>>>> >  >>Currently, we restart tx polling unconditionally when sendmsg()
>>>> >  >>fails. This would cause unnecessary wakeups of vhost wokers as it's
>>>> >  >>only needed when the socket send buffer were exceeded.
>>> >  >Why is this a problem?
>> >  
>> >  This issue is when guest driver is able to hit the -EFAULT, vhost
>> >  discard the the descriptor and restart the polling. This would wake
>> >  vhost thread and repeat the loop again which waste cpu.
> Does same thing happen if we get an error from copy from user?
>

Right, so do you think it makes sense that we only restart polling on 
-EAGAIN or -ENOBUFS?
