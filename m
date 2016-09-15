From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 03/22] bpf,landlock: Add a new arraymap type to deal with
 (Landlock) handles
Date: Thu, 15 Sep 2016 23:51:36 +0200
Message-ID: <57DB17E8.9000509@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-4-mic@digikod.net>
 <20160914185157.GA53542@ast-mbp.thefacebook.com>
 <57D9DBC9.2010605@digikod.net>
 <20160914232815.GE60248@ast-mbp.thefacebook.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="WLFibjtnJnf4cBIdDsaD4hMorTSFrVv4s"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
        netdev@vger.ker
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <kernel-hardening-return-4673-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914232815.GE60248@ast-mbp.thefacebook.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--WLFibjtnJnf4cBIdDsaD4hMorTSFrVv4s
Content-Type: multipart/mixed; boundary="wICN1dhgOea8bvfdPU4X9ikMbRRDF9btV";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
 Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, cgroups@vger.kernel.org
Message-ID: <57DB17E8.9000509@digikod.net>
Subject: Re: [RFC v3 03/22] bpf,landlock: Add a new arraymap type to deal with
 (Landlock) handles
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-4-mic@digikod.net>
 <20160914185157.GA53542@ast-mbp.thefacebook.com>
 <57D9DBC9.2010605@digikod.net>
 <20160914232815.GE60248@ast-mbp.thefacebook.com>
In-Reply-To: <20160914232815.GE60248@ast-mbp.thefacebook.com>

--wICN1dhgOea8bvfdPU4X9ikMbRRDF9btV
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable



On 15/09/2016 01:28, Alexei Starovoitov wrote:
> On Thu, Sep 15, 2016 at 01:22:49AM +0200, Micka=EBl Sala=FCn wrote:
>>
>> On 14/09/2016 20:51, Alexei Starovoitov wrote:
>>> On Wed, Sep 14, 2016 at 09:23:56AM +0200, Micka=EBl Sala=FCn wrote:
>>>> This new arraymap looks like a set and brings new properties:
>>>> * strong typing of entries: the eBPF functions get the array type of=

>>>>   elements instead of CONST_PTR_TO_MAP (e.g.
>>>>   CONST_PTR_TO_LANDLOCK_HANDLE_FS);
>>>> * force sequential filling (i.e. replace or append-only update), whi=
ch
>>>>   allow quick browsing of all entries.
>>>>
>>>> This strong typing is useful to statically check if the content of a=
 map
>>>> can be passed to an eBPF function. For example, Landlock use it to s=
tore
>>>> and manage kernel objects (e.g. struct file) instead of dealing with=

>>>> userland raw data. This improve efficiency and ensure that an eBPF
>>>> program can only call functions with the right high-level arguments.=

>>>>
>>>> The enum bpf_map_handle_type list low-level types (e.g.
>>>> BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) which are identified when
>>>> updating a map entry (handle). This handle types are used to infer a=

>>>> high-level arraymap type which are listed in enum bpf_map_array_type=

>>>> (e.g. BPF_MAP_ARRAY_TYPE_LANDLOCK_FS).
>>>>
>>>> For now, this new arraymap is only used by Landlock LSM (cf. next
>>>> commits) but it could be useful for other needs.
>>>>
>>>> Changes since v2:
>>>> * add a RLIMIT_NOFILE-based limit to the maximum number of arraymap
>>>>   handle entries (suggested by Andy Lutomirski)
>>>> * remove useless checks
>>>>
>>>> Changes since v1:
>>>> * arraymap of handles replace custom checker groups
>>>> * simpler userland API
>>>>
>>>> Signed-off-by: Micka=EBl Sala=FCn <mic@digikod.net>
>>>> Cc: Alexei Starovoitov <ast@kernel.org>
>>>> Cc: Andy Lutomirski <luto@amacapital.net>
>>>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>>>> Cc: David S. Miller <davem@davemloft.net>
>>>> Cc: Kees Cook <keescook@chromium.org>
>>>> Link: https://lkml.kernel.org/r/CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEX=
h77FD2G5o71yD7g@mail.gmail.com
>>>> ---
>>>>  include/linux/bpf.h      |  14 ++++
>>>>  include/uapi/linux/bpf.h |  18 +++++
>>>>  kernel/bpf/arraymap.c    | 203 ++++++++++++++++++++++++++++++++++++=
+++++++++++
>>>>  kernel/bpf/verifier.c    |  12 ++-
>>>>  4 files changed, 246 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
>>>> index fa9a988400d9..eae4ce4542c1 100644
>>>> --- a/include/linux/bpf.h
>>>> +++ b/include/linux/bpf.h
>>>> @@ -13,6 +13,10 @@
>>>>  #include <linux/percpu.h>
>>>>  #include <linux/err.h>
>>>> =20
>>>> +#ifdef CONFIG_SECURITY_LANDLOCK
>>>> +#include <linux/fs.h> /* struct file */
>>>> +#endif /* CONFIG_SECURITY_LANDLOCK */
>>>> +
>>>>  struct perf_event;
>>>>  struct bpf_map;
>>>> =20
>>>> @@ -38,6 +42,7 @@ struct bpf_map_ops {
>>>>  struct bpf_map {
>>>>  	atomic_t refcnt;
>>>>  	enum bpf_map_type map_type;
>>>> +	enum bpf_map_array_type map_array_type;
>>>>  	u32 key_size;
>>>>  	u32 value_size;
>>>>  	u32 max_entries;
>>>> @@ -187,6 +192,9 @@ struct bpf_array {
>>>>  	 */
>>>>  	enum bpf_prog_type owner_prog_type;
>>>>  	bool owner_jited;
>>>> +#ifdef CONFIG_SECURITY_LANDLOCK
>>>> +	u32 n_entries;	/* number of entries in a handle array */
>>>> +#endif /* CONFIG_SECURITY_LANDLOCK */
>>>>  	union {
>>>>  		char value[0] __aligned(8);
>>>>  		void *ptrs[0] __aligned(8);
>>>> @@ -194,6 +202,12 @@ struct bpf_array {
>>>>  	};
>>>>  };
>>>> =20
>>>> +#ifdef CONFIG_SECURITY_LANDLOCK
>>>> +struct map_landlock_handle {
>>>> +	u32 type; /* enum bpf_map_handle_type */
>>>> +};
>>>> +#endif /* CONFIG_SECURITY_LANDLOCK */
>>>> +
>>>>  #define MAX_TAIL_CALL_CNT 32
>>>> =20
>>>>  struct bpf_event_entry {
>>>> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
>>>> index 7cd36166f9b7..b68de57f7ab8 100644
>>>> --- a/include/uapi/linux/bpf.h
>>>> +++ b/include/uapi/linux/bpf.h
>>>> @@ -87,6 +87,15 @@ enum bpf_map_type {
>>>>  	BPF_MAP_TYPE_PERCPU_ARRAY,
>>>>  	BPF_MAP_TYPE_STACK_TRACE,P_TYPE_CGROUP_ARRAY
>>>>  	BPF_MAP_TYPE_CGROUP_ARRAY,
>>>> +	BPF_MAP_TYPE_LANDLOCK_ARRAY,
>>>> +};
>>>> +
>>>> +enum bpf_map_array_type {
>>>> +	BPF_MAP_ARRAY_TYPE_UNSPEC,
>>>> +};
>>>> +
>>>> +enum bpf_map_handle_type {
>>>> +	BPF_MAP_HANDLE_TYPE_UNSPEC,
>>>>  };
>>>
>>> missing something. why it has to be special to have it's own
>>> fd array implementation?
>>> Please take a look how BPF_MAP_TYPE_PERF_EVENT_ARRAY,=20
>>> BPF_MAP_TYPE_CGROUP_ARRAY and BPF_MAP_TYPE_PROG_ARRAY are done.
>>> The all store objects into array map that user space passes via FD.
>>> I think the same model should apply here.
>>
>> The idea is to have multiple way for userland to describe a resource
>> (e.g. an open file descriptor, a path or a glob pattern). The kernel
>> representation could then be a "struct path *" or dedicated types (e.g=
=2E
>> custom glob).
>=20
> hmm. I think user space api should only deal with FD. Everything
> else is user space job to encapsulate/hide.

How would you create a FD referring to a glob, a user or port ranges for
example ?

>=20
>> Another interesting point (that could replace
>> check_map_func_compatibility()) is that BPF_MAP_TYPE_LANDLOCK_ARRAY
>> translate to dedicated (abstract) types (instead of CONST_PTR_TO_MAP)
>> thanks to bpf_reg_type_from_map(). This is useful to abstract userland=

>> (map) interface with kernel object(s) dealing with that type.
>=20
> I probably missing something. If user space interface is FD,
> to the kernel they're different object types. Nothing else.

Yes but what if there is more than one way to express a resource (cf.
previous comment). A FD can refer to an *existing file* but a glob
pattern could match a bunch of files (existing or not). This was a
concern for Kees Cook and James Morris [1].

[1]
https://lkml.kernel.org/r/CAGXu5jK1U12vMk11HD_x_gNz3Rk4ZgEfdThY7DHvm4e4sP=
Rh4g@mail.gmail.com

>=20
>> A third point is that BPF_MAP_TYPE_LANDLOCK_ARRAY is a kind of set. It=

>> is optimized to quickly walk through all the elements in a sequential =
way.
>=20
> why set is any faster to walk vs array?

It is an array with only sequential entries (i.e. no hole in the array).


--wICN1dhgOea8bvfdPU4X9ikMbRRDF9btV--

--WLFibjtnJnf4cBIdDsaD4hMorTSFrVv4s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX2xfoAAoJECLe/t9zvWqVBuwH/RNqcIvwCV6eTOojUMExZB+0
1W+2SgBByepoX5H2v/wncX9W0ltn96WaVkMGTdW+qQJo7JSwCtphU18U1mVM8e3u
G9Nqh+cwE4lrKft8Xax8XaV4u9Zf62GD1sC2j2tcwzk28WU2q6/DlQXJRnlKf/RU
IhRm3r6ueW4qHMhEhEFSDGVoOidj/32h88ZdWyOtVS5wwEbX4VxNulv4bvf1CY0U
P0V4vdUPs2dEVgyAsDOZaCThcLP85GiDfYQsk1JZnKGa5QsMDwOwQc6zaEuJCrR8
pf443zqfIzFagGZH5qMQ0ZVuLMRIZ5dnboob6durnCUWDX4f9JgLRjFHEUiVT5g=
=LyK9
-----END PGP SIGNATURE-----

--WLFibjtnJnf4cBIdDsaD4hMorTSFrVv4s--
