From: Yang Zhang <yang.zhang.wz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC] vhost: basic device IOTLB support
Date: Mon, 4 Jan 2016 09:39:37 +0800
Message-ID: <5689CD59.6030900@gmail.com>
References: <1451546025-15955-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1451546025-15955-1-git-send-email-jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2015/12/31 15:13, Jason Wang wrote:
> This patch tries to implement an device IOTLB for vhost. This could be
> used with for co-operation with userspace(qemu) implementation of
> iommu for a secure DMA environment in guest.
>
> The idea is simple. When vhost meets an IOTLB miss, it will request
> the assistance of userspace to do the translation, this is done
> through:
>
> - Fill the translation request in a preset userspace address (This
>    address is set through ioctl VHOST_SET_IOTLB_REQUEST_ENTRY).
> - Notify userspace through eventfd (This eventfd was set through ioctl
>    VHOST_SET_IOTLB_FD).
>
> When userspace finishes the translation, it will update the vhost
> IOTLB through VHOST_UPDATE_IOTLB ioctl. Userspace is also in charge of
> snooping the IOTLB invalidation of IOMMU IOTLB and use
> VHOST_UPDATE_IOTLB to invalidate the possible entry in vhost.

Is there any performance data shows the difference with IOTLB 
supporting? I doubt we may see performance decrease since the flush code 
path is longer than before.

-- 
best regards
yang
