From: Michel Machado <michel@digirati.com.br>
Subject: Re: Linux XIA - merge proposal
Date: Fri, 20 Mar 2015 14:46:05 -0400
Message-ID: <550C6AED.10909@digirati.com.br>
References: <54F5EF6E.9090303@digirati.com.br> <CAErSpo6hUHYXrdB0+1WysD=AMuX3eawqSokTngR4s2tmmuakqA@mail.gmail.com> <550301B6.3090302@digirati.com.br> <20150315093752.GA29005@kroah.com> <55081D48.3000407@digirati.com.br> <55095312.5080802@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Oded Gabbay <oded.gabbay@amd.com>,
	Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55095312.5080802@amd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/18/2015 06:27 AM, Oded Gabbay wrote:
 > Hi Michel,
 > If you want an example of how to break a fairly medium+
 > code-base/driver, I believe amdkfd is a good example. Originally, I had
 > dumped 80+ patches, but after getting some flames & help from drm devs,
 > I rearranged them into a nicely 25 patches:
 >
 > 1. Several patches that implements helper functions in other drivers
 > (mm, iommu, radeon)
 > 2. Patch to add IOCTL definitions (kfd_ioctl.h)
 > 3. Patch to add skeleton code base of driver
 > 4. Several patches that add different modules in the amdkfd driver
 > 5. Several patches that implement the IOCTLs in the amdkfd drivers
 >
 > See this link for the final set that was merged into 3.19-rc1:
 > http://cgit.freedesktop.org/~gabbayo/linux/?h=amdkfd-v6
 >
 > Take a look from commit "Merge branch 'drm-next-3.19'  to the HEAD of
 > the log.
 >
 > If you need additional advice, you can contact me.
 >
 >      Oded

Hi Oded,

    Thank you for your example. After thinking on how to get our 
repository as a set of patches, it became clear that I have to start 
with a new repository and gradually move the code from our current 
repository to this new one. Because the commits of the current 
repository follows how we arrived where we are now, and this makes the 
goal of only reviewing the final code harder.

    I'm going to take advantage that Linux XIA is broken down into 
kernel modules, and have a serie of patches for each module. With the 
exception of the core module, on which all other modules depend, all 
modules don't have dependencies between them. The problem I'm running 
into with this approach is that some patches will be large. For example, 
the core module has these files:

$ wc net/xia/*.c
    744   2246  15523 net/xia/dag.c
    897   2378  23006 net/xia/fib.c
    360    931   8240 net/xia/fib_frontend.c
     72    169   1486 net/xia/locktbl.c
    106    259   2116 net/xia/main.c
    281    858   7241 net/xia/output.c
   1471   4573  37952 net/xia/route.c
    598   1579  13783 net/xia/socket.c
    109    305   2852 net/xia/vxidty.c
   4638  13298 112199 total

    I can try to break these large patches into smaller ones, but this 
would likely break code coherence since each module is supposed to 
self-contained. My understanding is that you created skeletons to 
gradually fill them in to address similar issue, but I'm not sure how to 
do it in my case.

    I'll keep pounding on this task. Any advice is more than welcome.

    By the way, the new repository will be based on David Miller's -next 
networking tree:

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git

[ ]'s
Michel Machado
