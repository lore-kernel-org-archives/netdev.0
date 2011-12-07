From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [net-next RFC PATCH 5/5] virtio-net: flow director support
Date: Wed, 7 Dec 2011 09:08:57 +0000
Message-ID: <CAJSP0QUGWCf5WHEeCXzqZeF2CvpycxrGo-uPSfpWD1rWD3zeSg@mail.gmail.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
	<CAJSP0QXfHC8j2Kk9x6wyBMubo2=YvpaLAShJtwMWA2mtro6UhA@mail.gmail.com>
	<4EDDB71F.9080908@redhat.com>
	<CAJSP0QX5dDkpX+cRcQut2mb6K91zeqGLRrZBGAWT_r2p685gaQ@mail.gmail.com>
	<4EDDECA9.8060808@redhat.com>
	<CAJSP0QXsLwvH5xYj6h0E_V4VLg6DuUc-GKXu9esEYzL2MFcFGw@mail.gmail.com>
	<4EDED785.80804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, bhutchings@solarflare.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4EDED785.80804@redhat.com>
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

On Wed, Dec 7, 2011 at 3:03 AM, Jason Wang <jasowang@redhat.com> wrote:
> On 12/06/2011 09:15 PM, Stefan Hajnoczi wrote:
>>
>> On Tue, Dec 6, 2011 at 10:21 AM, Jason Wang<jasowang@redhat.com> =A0wrot=
e:
>>>
>>> On 12/06/2011 05:18 PM, Stefan Hajnoczi wrote:
>>>>
>>>> On Tue, Dec 6, 2011 at 6:33 AM, Jason Wang<jasowang@redhat.com>
>>>> =A0wrote:
>>>>>
>>>>> On 12/05/2011 06:55 PM, Stefan Hajnoczi wrote:
>>>>>>
>>>>>> On Mon, Dec 5, 2011 at 8:59 AM, Jason Wang<jasowang@redhat.com>
>>>>>> =A0wrote:
>>>>
>>>> The vcpus are just threads and may not be bound to physical CPUs, so
>>>> what is the big picture here? =A0Is the guest even in the position to
>>>> set the best queue mappings today?
>>>
>>>
>>> Not sure it could publish the best mapping but the idea is to make sure
>>> the
>>> packets of a flow were handled by the same guest vcpu and may be the sa=
me
>>> vhost thread in order to eliminate the packet reordering and lock
>>> contention. But this assumption does not take the bouncing of vhost or
>>> vcpu
>>> threads which would also affect the result.
>>
>> Okay, this is why I'd like to know what the big picture here is. =A0What
>> solution are you proposing? =A0How are we going to have everything from
>> guest application, guest kernel, host threads, and host NIC driver
>> play along so we get the right steering up the entire stack. =A0I think
>> there needs to be an answer to that before changing virtio-net to add
>> any steering mechanism.
>
>
> Consider the complexity of the host nic each with their own steering
> features, =A0this series make the first step with minimal effort to try t=
o let
> guest driver and host tap/macvtap co-operate like what physical nic does.
> There may be other method, but performance numbers is also needed to give
> the answer.

I agree that performance results for this need to be shown.

My original point is really that it's not a good idea to take
individual steps without a good big picture because this will change
the virtio-net device specification.  If this turns out to be a dead
end then hosts will need to continue to support the interface forever
(legacy guests could still try to use it).  So please first explain
what the full stack picture is going to look like and how you think it
will lead to better performance.  You don't need to have all the code
or evidence, but just enough explanation so we see where this is all
going.

Stefan
