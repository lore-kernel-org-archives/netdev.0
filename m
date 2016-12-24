From: Geoff Lansberry <geoff@kuvee.com>
Subject: Re: [PATCH v3 3/3] nfc: trf7970a: Prevent repeated polling from
 crashing the kernel
Date: Sat, 24 Dec 2016 11:17:18 -0500
Message-ID: <CAO7Z3W+n85jbr8cmj3HJV1c+eL=oRh-XRy+O=iZ+mD=ov2WABA@mail.gmail.com>
References: <1482380314-16440-1-git-send-email-geoff@kuvee.com>
 <1482380314-16440-3-git-send-email-geoff@kuvee.com> <20161224060141.GA9069@animalcreek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Samuel Ortiz <sameo@linux.intel.com>, robh+dt@kernel.org,
        mark.rutland@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        Justin Bronder <justin@kuvee.com>,
        Jaret Cantu <jaret.cantu@timesys.com>
To: Mark Greer <mgreer@animalcreek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161224060141.GA9069@animalcreek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark - I'm sorry, but I did not write this code, and therefore was not
able to accurately describe it.   It is fixing a different issue, not
the neard segfault that we are still chasing. Last week Jaret Cantu
sent a separate email explaining the purpose of the code, which had
you copied, did you see that?   Does it explain why it was done to
your satisfaction?   I've asked him to join in on the effort to push
the change upstream, however he will not be available until the new
year.

I know you did suggest that we split off that change from the others,
and if now is the time to do that, let me know.   If you don't have
the email from Jaret, also please let me know and I will forward it to
you.

Geoff
Geoff Lansberry


Engineering Guy
Kuv=C3=A9e, Inc
125 Kingston St., 3rd Floor
Boston, MA 02111
1-617-290-1118 (m)
geoff.lansberry (skype)
http://www.kuvee.com



On Sat, Dec 24, 2016 at 1:01 AM, Mark Greer <mgreer@animalcreek.com> wrote:
> On Wed, Dec 21, 2016 at 11:18:34PM -0500, Geoff Lansberry wrote:
>> From: Jaret Cantu <jaret.cantu@timesys.com>
>>
>> Repeated polling attempts cause a NULL dereference error to occur.
>> This is because the state of the trf7970a is currently reading but
>> another request has been made to send a command before it has finished.
>>
>> The solution is to properly kill the waiting reading (workqueue)
>> before failing on the send.
>>
>> Signed-off-by: Geoff Lansberry <geoff@kuvee.com>
>> ---
>
> You've still provided virtually no information on the actual problem(s)
> nor justified why you think this is the best solution.  You're adding
> code to a section of code that should _never_ be executed so the only
> reasonable things I can infer is that there are, at least, two problems:
>
> 1) There is a bug causing execution to get into this block of code.
>
> 2) Once in this block of code, there is another bug.
>
> You seem to be attempting to fix 2) and completely ignoring 1).
> 1) is the first bug that needs to be root-caused and fixed.
>
> Also, what exactly is the "NULL dereference error" you mention?
> Is this the neard crash you talked about in another thread or is
> this a kernel crash?  If it is the kernel crash, please post the
> relevant information.  If this is the neard crash - which seems
> unlikely - then how can changing a section of kernel code that
> shouldn't be executed in the first place fix that?
>
> Mark
> --
