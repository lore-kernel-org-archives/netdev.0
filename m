From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace instances
Date: Thu, 14 May 2015 23:23:09 -0700
Message-ID: <CALCETrWzM4+Vs8OVJWBcWJfbR_DRSb+e7SmUyy6CS4sHQaTkRw@mail.gmail.com>
References: <cover.1429252659.git.rgb@redhat.com> <20150512195759.GA9832@madcap2.tricolour.ca>
 <2918460.dpKocsKt4o@x2> <12675437.ssZNCck7zG@sifl> <20150515023221.GC965@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>,
	arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
	Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150515023221.GC965-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 14, 2015 at 7:32 PM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 15/05/14, Paul Moore wrote:
>> * Look at our existing audit records to determine which records should have
>> namespace and container ID tokens added.  We may only want to add the
>> additional fields in the case where the namespace/container ID tokens are not
>> the init namespace.
>
> If we have a record that ties a set of namespace IDs with a container
> ID, then I expect we only need to list the containerID along with auid
> and sessionID.

The problem here is that the kernel has no concept of a "container", and I
don't think it makes any sense to add one just for audit.  "Container" is a
marketing term used by some userspace tools.

I can imagine that both audit could benefit from a concept of a
namespace *path* that understands nesting (e.g. root/2/5/1 or
something along those lines).  Mapping these to "containers" belongs
in userspace, I think.

--Andy
