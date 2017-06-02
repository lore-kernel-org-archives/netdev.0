From: "Yan, Zheng" <ukernel@gmail.com>
Subject: Re: [PATCH 04/12] fs: ceph: CURRENT_TIME with ktime_get_real_ts()
Date: Fri, 2 Jun 2017 19:18:53 +0800
Message-ID: <CAAM7YAk8JNU=XV=sOCczagWjBimO4JSPU08th7E4u6FTJN--9A@mail.gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
 <1491613030-11599-5-git-send-email-deepa.kernel@gmail.com>
 <CAAM7YAmp=cZKqGHa8UqDnrQLCe+6TKx+7w9SDZv4cW5fr4dfvA@mail.gmail.com>
 <CAK8P3a1pCw1Oo-Wg70kH5L12pbtEzGDfaPZ8g6ErERJjvY8znQ@mail.gmail.com>
 <CAAM7YAnWLUXMOCVbgfdKGfvK04EtAQcz-ETm7xFO=8Y=_fCvOQ@mail.gmail.com>
 <CALAqxLV-yVKWM5es7fAFiDzhSQmtZFiZDPQwBRUYbWUtqhoWVg@mail.gmail.com>
 <CABeXuvqvLr6sSGF+rZEXXxpCBDKTOeLX1ObSjbPPY4aFBuwvMg@mail.gmail.com>
 <CAAM7YAkXNo_69tOrw6a5kpyref9nEpEp-2vxBbFVSHGmAVbt+A@mail.gmail.com>
 <CAK8P3a1TwkVRCwDWqgYE8Z3wZT2+v6xayq=dVeW8KaHmO0W4cg@mail.gmail.com>
 <CAAM7YA=BJHFLz_Ud==7L=yCzxj+1sjctc68tvpNogPhiSxxELQ@mail.gmail.com>
 <CAK8P3a0D3EXuwBj+sSVL9cmpysdvQWXnkE0zEctBJS8XOqhX7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yuchao0@huawei.com, "J. Bruce Fields" <bfields@fieldses.org>,
 Chris Mason <clm@fb.com>, linux-mtd <linux-mtd@lists.infradead.org>,
 Deepa Dinamani <deepa.kernel@gmail.com>, Evgeniy Dushistov <dushistov@mail.ru>,
 Jeff Layton <jlayton@poochiereds.net>, ceph-devel <ceph-devel@vger.kernel.org>,
 devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org,
 Paul Moore <paul@paul-moore.com>, y2038 Mailman List <y2038@lists.linaro.org>,
 Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Drokin,
 Oleg" <oleg.drokin@intel.com>, John Stultz <john.stultz@linaro.org>,
 Al Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.com>,
 Jaegeuk Kim <jaegeuk@kernel.org>, Thomas Gleixner <tglx@linutronix.de>,
 "Dilger, Andreas" <andreas.dilger@intel.com>, Josef Bacik <jbacik@fb.com>,
 gregkh <gregkh@linuxfoundation.org>, samba-technical@lists.samba.org,
 Linux Kernel Mailing List
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CAK8P3a0D3EXuwBj+sSVL9cmpysdvQWXnkE0zEctBJS8XOqhX7A@mail.gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Fri, Jun 2, 2017 at 6:51 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Fri, Jun 2, 2017 at 12:10 PM, Yan, Zheng <ukernel@gmail.com> wrote:
>> On Fri, Jun 2, 2017 at 5:45 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>>> On Fri, Jun 2, 2017 at 4:09 AM, Yan, Zheng <ukernel@gmail.com> wrote:
>>>> On Fri, Jun 2, 2017 at 8:57 AM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>>>>> On Thu, Jun 1, 2017 at 5:36 PM, John Stultz <john.stultz@linaro.org> wrote:
>>>>>> On Thu, Jun 1, 2017 at 5:26 PM, Yan, Zheng <ukernel@gmail.com> wrote:
>>>
>>> I believe the bug you see is the result of the two timestamps
>>> currently being almost guaranteed to be different in the latest
>>> kernels.
>>> Changing r_stamp to use current_kernel_time() will make it the
>>> same value most of the time (as it was before Deepa's patch),
>>> but when the timer interrupt happens between the timestamps,
>>> the two are still different, it's just much harder to hit.
>>>
>>> I think the proper solution should be to change __ceph_setattr()
>>> in a way that has req->r_stamp always synchronized with i_ctime.
>>> If we copy i_ctime to r_stamp, that will also take care of the
>>> future issues with the planned changes to current_time().
>>>
>> I already have a patch
>> https://github.com/ceph/ceph-client/commit/24f54cd18e195a002ee3d2ab50dbc952fd9f82af
>
> Looks good to me. In case anyone cares:
> Acked-by: Arnd Bergmann <arnd@arndb.de>
>
>>> The part I don't understand is what else r_stamp (i.e. the time
>>> stamp in ceph_msg_data with type==
>>> CEPH_MSG_CLIENT_REQUEST) is used for, other than setting
>>> ctime in CEPH_MDS_OP_SETATTR.
>>>
>>> Will this be used to update the stored i_ctime for other operations
>>> too? If so, we would need to synchronize it with the in-memory
>>> i_ctime for all operations that do this.
>>>
>>
>> yes,  mds uses it to update ctime of modified inodes. For example,
>> when handling mkdir, mds set ctime of both parent inode and new inode
>> to r_stamp.
>
> I see, so we may have a variation of that problem there as well: From
> my reading of the code, the child inode is not in memory yet, so
> that seems fine, but I could not find where the parent in-memory inode
> i_ctime is updated in ceph, but it is most likely not the same as
> req->r_stamp (assuming it gets updated at all).

i_ctime is updated when handling request reply, by ceph_fill_file_time().
__ceph_setattr() can update the in-memory inode's ctime after request
reply is received. The difference between ktime_get_real_ts() and
current_time() can be larger than round-trip time of request. So it's
still possible that __ceph_setattr() make ctime go back.

Regards
Yan, Zheng


>
> Would it make sense require all callers of ceph_mdsc_do_request()
> to update r_stamp at the same time as i_ctime to keep them in sync?
>
>         Arnd
