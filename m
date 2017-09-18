From: Cole Robinson <crobinso@redhat.com>
Subject: Re: [PATCH 0/3] fix reuseaddr regression
Date: Mon, 18 Sep 2017 13:44:32 -0400
Message-ID: <5df48cbb-2726-3e99-84e7-eb6c6fc0dbb2@redhat.com>
References: <1505752137-15522-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: josef@toxicpanda.com, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, labbott@redhat.com,
        kernel-team@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505752137-15522-1-git-send-email-jbacik@fb.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/18/2017 12:28 PM, josef@toxicpanda.com wrote:
> I introduced a regression when reworking the fastreuse port stuff that allows
> bind conflicts to occur once a reuseaddr socket successfully opens on an
> existing tb.  The root cause is I reversed an if statement which caused us to
> set the tb as if there were no owners on the socket if there were, which
> obviously is not correct.
> 
> Dave I have follow up patches that will add a selftest for this case and I ran
> the other reuseport related tests as well.  These need to go in pretty quickly
> as it breaks kvm, I've marked them for stable.  Sorry for the regression,
> 

To clarify, it doesn't really break KVM specifically, but it breaks a
port collision detection idiom that libvirt depends on to successfully
launch qemu/xen/... VMs in certain cases.

Thanks,
Cole
